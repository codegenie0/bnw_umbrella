defmodule BnwDashboardWeb.PlugsApp.NbxTrucking.NbxTruckingLive do

  use BnwDashboardWeb, :live_view

  alias BnwDashboardWeb.PlugsApp.Helpers.{
    ModalComponent,
    TableLive,
    SearchLive,
    ChangeReportComponent
  }
  alias BnwDashboardWeb.PlugsApp.NbxTrucking.{
    ChangeDepartmentComponent
  }
  alias PlugsApp.{
    NbxTruckings,
    NbxTruckingDepartments,
    Authorize,
    Reports,
    Users
  }

  defp get_role(socket) do
    current_user = Map.get(socket.assigns, :current_user)
    if current_user do
      Authorize.authorize(current_user, "nbx_trucking")
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

  defp init_args(socket) do
    %{
      selected_department: selected_department,
      departments: departments,
    } = socket.assigns

    args = [
      %{type: :date,      special: nil,  name: :start_date, display_name: "Month"},
      %{type: :number,    special: :int, name: :truck,      display_name: "Truck", step: 1},
      %{type: :drop_down, special: nil,  name: :dept,       display_name: "Department", selected: selected_department, list: departments},
      %{type: :number,    special: :int, name: :miles,      display_name: "Miles", step: 1},
      %{type: :number,    special: :int, name: :tons,       display_name: "Tons", step: 1},
    ]

    assign(socket, args: args)
  end

  defp fetch_permissions(socket) do
    role = get_role(socket)
    it_admin = socket.assigns.current_user.it_admin
    is_admin = role == "admin"
    is_edit  = role == "admin" or role == "edit"
    assign(socket, it_admin: it_admin, is_admin: is_admin, is_edit: is_edit)
  end

  defp fetch_items(plug) do
    department = Map.get(plug, :dept, 0)
    |> NbxTruckingDepartments.get_plug()

    Map.put(plug, :dept, department)
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
      NbxTruckings.list_plugs(page, per_page, search_col, search)
      |> Enum.map(&(fetch_items(&1)))
      |> Enum.map(&(NbxTruckings.change_plug(&1)))
    assign(socket, plugs: pre_plugs ++ plugs)
  end

  defp fetch_extra(socket) do
    departments = NbxTruckingDepartments.list_plugs()
    assign(socket, departments: departments)
  end

  defp fetch_plug_extra(socket) do
    departments = NbxTruckingDepartments.list_all_plugs()
    assign(socket, plug_departments: departments)
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
      |> assign(page_title: "BNW Dashboard · Plugs NBX Trucking",
                app: "Plugs",
                add_more: false,
                selected_department: nil,
                departments: nil,
                modal: nil,
                update_action: "replace",
                page: page,
                plug: "nbx_trucking",
                selected_search_col: :start_date,
                search: "",
                per_page: per_page)
      |> fetch_plugs()
      |> fetch_extra()
      |> fetch_permissions()
      |> init_args()
      |> init_reports()

    if connected?(socket) do
      NbxTruckings.subscribe()
      NbxTruckingDepartments.subscribe()
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
  def handle_info({[:nbx_trucking_department, :created_or_updated], _}, socket) do
    socket = socket
    |> fetch_extra()
    |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:nbx_trucking_department, :deleted], _}, socket) do
    socket = socket
    |> fetch_extra()
    |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:nbx_trucking, :created_or_updated_add_more], _}, socket) do
    changeset =
      NbxTruckings.new_plug()
      |> NbxTruckings.change_plug()
    socket = assign(socket,
      changeset: changeset,
      modal: :change_plug,
      modal_title: "New NBX Trucking",
      selected_department: 1)
    |> assign(page: 1, plugs: [])
    |> fetch_plugs()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:nbx_trucking, :created_or_updated], _}, socket) do
    socket = assign(socket, page: 1, plugs: [])
    |> fetch_plugs()
      |> assign(modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:nbx_trucking, :deleted], _}, socket) do
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
    %{ departments: departments} = socket.assigns
    department = Enum.find(departments, fn x-> x[:key] == cur.data.dept end)[:value]
    socket = assign(socket,
      changeset: cur,
      modal: :change_plug,
      modal_title: "Edit NBX Trucking",
      selected_department: department)
    |> init_args()
    {:noreply, socket}
  end

  @impl true
  def handle_event("new", _, socket) do
    changeset =
      NbxTruckings.new_plug()
      |> NbxTruckings.change_plug()
    socket = assign(socket,
      changeset: changeset,
      modal: :change_plug,
      modal_title: "New NBX Trucking",
      selected_department: 1)
    |> init_args()
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit_departments", _, socket) do
    socket = assign(socket,
      modal: :change_department,
      modal_title: "Manage Departments")
    |> fetch_plug_extra()
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
    NbxTruckings.delete_plug(cur.data)
    {:noreply, socket}
  end

  def handle_event("save", %{"nbx_trucking" => plug}, socket) do
    %{changeset: changeset, add_more: add_more} = socket.assigns

    changeset = NbxTruckings.validate(changeset.data, plug)
    if changeset.valid? do
      case NbxTruckings.create_or_update_plug(changeset.data, plug, add_more) do
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

  def handle_event("validate", %{"nbx_trucking" => plug}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = NbxTruckings.validate(changeset.data, plug)

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
        modal_title: "NBX Trucking Reports")}
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
