defmodule BnwDashboardWeb.PlugsApp.MpcComparison.MpcComparisonLive do

  use BnwDashboardWeb, :live_view

  alias BnwDashboardWeb.PlugsApp.Helpers.{
    ModalComponent,
    TableLive,
    SearchLive,
    ChangeReportComponent
  }
  alias PlugsApp.{
    MpcComparisons,
    Authorize,
    Reports,
    Users
  }

  defp get_role(socket) do
    current_user = Map.get(socket.assigns, :current_user)
    if current_user do
      Authorize.authorize(current_user, "mpc_comparisons")
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
      %{type: :date,    special: nil,       name: :week_end_date, display_name: "Week End Date"},
      %{type: :date_ro, special: nil,       name: :monday_date,   display_name: "Monday Date"},
      %{type: :number,  special: :currency, name: :c_fax_price,   display_name: "C-Fax Price", step: 0.01},
      %{type: :notes,   special: nil,       name: :c_fax_notes,   display_name: "Notes"},
      %{type: :number,  special: :currency, name: :usda_price,    display_name: "USDA Price", step: 0.01},
      %{type: :notes,   special: nil,       name: :usda_notes,    display_name: "Notes"},
      %{type: :number,  special: :currency, name: :tt_price,      display_name: "Texas Top Price", step: 0.01},
      %{type: :notes,   special: nil,       name: :tt_notes,      display_name: "Notes"},
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
      MpcComparisons.list_plugs(page, per_page, search_col, search)
      |> Enum.map(&(MpcComparisons.change_plug(&1)))
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
      |> assign(page_title: "BNW Dashboard · Plugs MPC Comparison",
                app: "Plugs",
                add_more: false,
                modal: nil,
                update_action: "replace",
                page: page,
                plug: "mpc_comparison",
                selected_search_col: :week_end_date,
                search: "",
                per_page: per_page)
      |> fetch_plugs()
      |> fetch_permissions()
      |> init_args()
      |> init_reports()

    if connected?(socket) do
      MpcComparisons.subscribe()
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
  def handle_info({[:mpc_comparison, :created_or_updated_add_more], _}, socket) do
    changeset =
      MpcComparisons.new_plug()
      |> MpcComparisons.change_plug()
    socket = assign(socket,
      changeset: changeset,
      modal: :change_plug,
      modal_title: "New MPC Comparison")
    |> assign(page: 1, plugs: [])
    |> fetch_plugs()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:mpc_comparison, :created_or_updated], _}, socket) do
    socket = assign(socket, page: 1, plugs: [])
    |> fetch_plugs()
      |> assign(modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:mpc_comparison, :deleted], _}, socket) do
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
    socket = assign(socket, changeset: cur, modal: :change_plug, modal_title: "Edit MPC Comparison")
    |> init_args()
    {:noreply, socket}
  end

  @impl true
  def handle_event("new", _, socket) do
    changeset =
      MpcComparisons.new_plug()
      |> MpcComparisons.change_plug()
    socket = assign(socket, changeset: changeset, modal: :change_plug, modal_title: "New MPC Comparison")
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
    MpcComparisons.delete_plug(cur.data)
    {:noreply, socket}
  end

  def handle_event("save", %{"mpc_comparison" => plug}, socket) do
    %{changeset: changeset, add_more: add_more} = socket.assigns

    changeset = MpcComparisons.validate(changeset.data, plug)
    if changeset.valid? do
      case MpcComparisons.create_or_update_plug(changeset.data, plug, add_more) do
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

  def handle_event("validate", %{"mpc_comparison" => plug}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = MpcComparisons.validate(changeset.data, plug)

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
        modal_title: "MPC Comparison Reports")}
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
