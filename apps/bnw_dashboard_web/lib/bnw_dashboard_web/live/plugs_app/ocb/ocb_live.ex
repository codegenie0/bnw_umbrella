defmodule BnwDashboardWeb.PlugsApp.Ocb.OcbLive do

  use BnwDashboardWeb, :live_view

  alias BnwDashboardWeb.PlugsApp.Helpers.{
    ModalComponent,
    TableLive,
    SearchLive,
    ChangeReportComponent
  }
  alias PlugsApp.{
    Ocbs,
    Authorize,
    Reports,
    Users
  }

  defp get_role(socket) do
    current_user = Map.get(socket.assigns, :current_user)
    if current_user do
      Authorize.authorize(current_user, "ocb")
    else
      ""
    end
  end

  defp authenticate(socket) do
    case get_role(socket) do
      "admin" -> true
      "edit"  -> true
      "view"  -> true
      _       -> false
    end
  end

  defp fetch_permissions(socket) do
    role = get_role(socket)
    it_admin = socket.assigns.current_user.it_admin
    is_admin = role == "admin"
    is_edit  = role == "admin" or role == "edit"
    assign(socket, it_admin: it_admin, is_admin: is_admin, is_edit: is_edit)
  end

  defp init_args(socket) do
    args = [
      %{type: :number, special: :int, name: :carcass_low,            display_name: "Carcass Low",            step: 1},
      %{type: :number, special: :int, name: :carcass_high,           display_name: "Carcass High",           step: 1},
      %{type: :number, special: nil,  name: :calculated_yield_grade, display_name: "Calculated Yield Grade", step: 0.01},
      %{type: :text,   special: nil,  name: :quality_grade,          display_name: "Quality Grade"},
      %{type: :number, special: :int, name: :add_30,                 display_name: "Add 30",                 step: 1},
      %{type: :number, special: :int, name: :add_ag,                 display_name: "Add AG",                 step: 1},
    ]

    assign(socket, args: args)
  end

  defp fetch_plugs(socket) do
    %{
      page: page,
      per_page: per_page,
      search: search,
      selected_search_col: search_col
    } = socket.assigns
    pre_plugs = Map.get(socket.assigns, :plugs, [])

    plugs =
      Ocbs.list_plugs(page, per_page, search_col, search)
      |> Enum.map(&(Ocbs.change_plug(&1)))
    assign(socket, plugs: pre_plugs ++ plugs)
  end

  defp init_reports(socket) do
    %{plug: plug} = socket.assigns
    reports = Reports.list_reports(plug)

    assign(socket, can_show_reports: Enum.count(reports) > 0, reports: reports)
  end

  @impl true
  def mount(_params, session, socket) do
    page = 1
    per_page = 20
    socket =
      assign_defaults(session, socket)
      |> assign(page_title: "BNW Dashboard · Plugs OCB",
                app: "Plugs",
                add_more: false,
                modal: nil,
                update_action: "replace",
                page: page,
                plug: "ocb",
                selected_search_col: :carcass_low,
                search: "",
                per_page: per_page)
      |> fetch_plugs()
      |> fetch_permissions()
      |> init_args()
      |> init_reports()

    if connected?(socket) do
      Ocbs.subscribe()
      Reports.subscribe()
      Users.subscribe()
    end

    case authenticate(socket) do
      true -> {:ok, socket}
      false -> {:ok, redirect(socket, to: "/")}
    end
  end

  @impl true
  def handle_params(_, _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:ocb, :created_or_updated_add_more], _}, socket) do
    changeset =
      Ocbs.new_plug()
      |> Ocbs.change_plug()
    socket = assign(socket,
      changeset: changeset,
      modal: :change_plug,
      modal_title: "New Projected Breakeven",
      selected_yard: 1)
    |> assign(page: 1, plugs: [])
    |> fetch_plugs()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:ocb, :created_or_updated], _}, socket) do
    socket = assign(socket, page: 1, plugs: [])
    |> fetch_plugs()
      |> assign(modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:ocb, :deleted], _}, socket) do
    socket = assign(socket, page: 1, plugs: [])
    |> fetch_plugs()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:report, :created_or_updated], _}, socket) do
    socket = init_reports(socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:report, :deleted], _}, socket) do
    socket = init_reports(socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:user, :updated], _plug}, socket) do
    case authenticate(socket) do
      true -> {:noreply, fetch_permissions(socket)}
      false -> {:noreply, redirect(socket, to: "/")}
    end
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    cur = Enum.find(socket.assigns.plugs, fn u -> u.data.id == id end)
    %{yards: yards} = socket.assigns
    yard = Enum.find(yards, fn x-> x[:key] == cur.data.yard end)[:value]

    socket = assign(socket,
      changeset: cur,
      modal: :change_plug,
      modal_title: "Edit Projected Breakeven",
      selected_yard: yard)
      |> init_args()
    {:noreply, socket}
  end

  @impl true
  def handle_event("new", _, socket) do
    changeset =
      Ocbs.new_plug()
      |> Ocbs.change_plug()
    socket = assign(socket,
      changeset: changeset,
      modal: :change_plug,
      modal_title: "New Projected Breakeven",
      selected_yard: 1)
      |> init_args()
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, changest: nil, modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    cur = Enum.find(socket.assigns.plugs, fn u -> u.data.id == id end)
    Ocbs.delete_plug(cur.data)
    {:noreply, socket}
  end

  def handle_event("save", %{"ocb" => plug}, socket) do
    %{changeset: changeset, add_more: add_more} = socket.assigns

    changeset = Ocbs.validate(changeset.data, plug)
    if changeset.valid? do
      case Ocbs.create_or_update_plug(changeset.data, plug, add_more) do
        {:ok, _plug} ->
          {:noreply, socket}
        {:error, %Ecto.Changeset{} = changest} ->
          {:noreply, assign(socket, changeset: changest)}
      end
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("add_more", _, socket) do
    {:noreply, assign(socket, add_more: true)}
  end

  def handle_event("done", _, socket) do
    {:noreply, assign(socket, add_more: false)}
  end

  def handle_event("validate", %{"ocb" => plug}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = Ocbs.validate(changeset.data, plug)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("load_more", _, socket) do
    %{
      page: page
    } = socket.assigns
    page = page + 1
    socket = assign(socket, update_action: "append", page: page)

    {:noreply, fetch_plugs(socket)}
  end

  def handle_event("show_reports", _, socket) do
    {:noreply, assign(socket,
        modal: :show_reports,
        modal_title: "OCB Reports")}
  end

  def handle_event("search", %{"search" => params}, socket) do
    %{
      selected_search_col: prev_col,
      search: prev_search
    } = socket.assigns
    %{
      "search" => search,
      "search_col" => search_col
    } = params

    search_col = String.to_atom(search_col)

    search =
    if prev_col == search_col do
      search
    else
      ""
    end

    socket = assign(socket,
      selected_search_col: search_col,
      search: search
    )

    socket =
    if search_col &&
    (search != "" ||
      prev_search != "") do
      assign(socket, page: 1, plugs: [])
      |> fetch_plugs()
    else
      socket
    end
    {:noreply, socket}
  end
end
