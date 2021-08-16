defmodule BnwDashboardWeb.PlugsApp.FuelUsage.FuelUsageLive do

  use BnwDashboardWeb, :live_view

  alias BnwDashboardWeb.PlugsApp.Helpers.{
    ModalComponent,
    TableLive,
    SearchLive,
    ChangeReportComponent
  }
  alias BnwDashboardWeb.PlugsApp.FuelUsage.{
    ChangeDepartmentComponent,
    ChangeTypeComponent,
    ChangeYardComponent
  }
  alias PlugsApp.{
    FuelUsages,
    FuelUsageDepartments,
    FuelUsageTypes,
    FuelUsageYards,
    Authorize,
    Reports,
    Users
  }

  defp get_role(socket) do
    current_user = Map.get(socket.assigns, :current_user)
    if current_user do
      Authorize.authorize(current_user, "fuel_usage")
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
    %{
      selected_department: selected_department,
      selected_type: selected_type,
      selected_yard: selected_yard,
      departments: departments,
      types: types,
      yards: yards,
    } = socket.assigns

    args = [
      %{type: :date,      special: nil,       name: :start_date,   display_name: "Month"},
      %{type: :drop_down, special: nil,       name: :yard,         display_name: "Yard", selected: selected_yard, list: yards},
      %{type: :drop_down, special: nil,       name: :type,         display_name: "Type", selected: selected_type, list: types},
      %{type: :drop_down, special: nil,       name: :department,   display_name: "Department", selected: selected_department, list: departments},
      %{type: :number,    special: :int,      name: :gallons,      display_name: "Gallons Used", step: 1},
      %{type: :number,    special: :currency, name: :amount,       display_name: "Total $ Amount",       step: 0.01},
      %{type: :disp_only, special: :currency, name: :price_gallon, display_name: "$/Gallon"},
    ]

    assign(socket, args: args)
  end

  defp fetch_items(plug) do
    department = Map.get(plug, :department, 0)
    |> FuelUsageDepartments.get_plug()

    type = Map.get(plug, :type, 0)
    |> FuelUsageTypes.get_plug()

    yard = Map.get(plug, :yard, 0)
    |> FuelUsageYards.get_plug()

    Map.put(plug, :department, department)
    |> Map.put(:type, type)
    |> Map.put(:yard, yard)
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
      FuelUsages.list_plugs(page, per_page, search_col, search)
      |> Enum.map(&(fetch_items(&1)))
      |> Enum.map(&(FuelUsages.change_plug(&1)))
    assign(socket, plugs: pre_plugs ++ plugs)
  end

  defp fetch_extra(socket) do
    departments = FuelUsageDepartments.list_plugs()
    types       = FuelUsageTypes.list_plugs()
    yards       = FuelUsageYards.list_plugs()
    assign(socket,
      departments: departments,
      types: types,
      yards: yards
    )
  end

  defp fetch_plug_extra(socket) do
    departments = FuelUsageDepartments.list_all_plugs()
    types       = FuelUsageTypes.list_all_plugs()
    yards       = FuelUsageYards.list_all_plugs()
    assign(socket,
      plug_departments: departments,
      plug_types: types,
      plug_yards: yards
    )
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
      |> assign(page_title: "BNW Dashboard · Plugs Fuel Usage",
                app: "Plugs",
                add_more: false,
                selected_department: nil,
                selected_type: nil,
                selected_yard: nil,
                modal: nil,
                update_action: "replace",
                page: page,
                plug: "fuel_usage",
                selected_search_col: :start_date,
                search: "",
                per_page: per_page)
      |> fetch_plugs()
      |> fetch_extra()
      |> fetch_permissions()
      |> init_args()
      |> init_reports()

    if connected?(socket) do
      FuelUsages.subscribe()
      FuelUsageDepartments.subscribe()
      FuelUsageTypes.subscribe()
      FuelUsageYards.subscribe()
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
  def handle_info({[:fuel_usage_department, :created_or_updated], _}, socket) do
    socket = assign(socket, page: 1, plugs: [])
    |> fetch_plugs()
    |> fetch_extra()
    |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:fuel_usage_type, :created_or_updated], _}, socket) do
    socket = assign(socket, page: 1, plugs: [])
    |> fetch_plugs()
    |> fetch_extra()
    |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:fuel_usage_yard, :created_or_updated], _}, socket) do
    socket = assign(socket, page: 1, plugs: [])
    |> fetch_plugs()
    |> fetch_extra()
    |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:fuel_usage_department, :deleted], _}, socket) do
    socket = assign(socket, page: 1, plugs: [])
    |> fetch_plugs()
    |> fetch_extra()
    |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:fuel_usage_type, :deleted], _}, socket) do
    socket = assign(socket, page: 1, plugs: [])
    |> fetch_plugs()
    |> fetch_extra()
    |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:fuel_usage_yard, :deleted], _}, socket) do
    socket = assign(socket, page: 1, plugs: [])
    |> fetch_plugs()
    |> fetch_extra()
    |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:fuel_usage, :created_or_updated_add_more], _}, socket) do
    changeset =
      FuelUsages.new_plug()
      |> FuelUsages.change_plug()
    socket = assign(socket,
      changeset: changeset,
      modal: :change_plug,
      selected_department: 1,
      selected_type:       1,
      selected_yard:       1,
      modal_title: "New Fuel Usage")
    |> assign(page: 1, plugs: [])
    |> fetch_plugs()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:fuel_usage, :created_or_updated], _}, socket) do
    socket = assign(socket, page: 1, plugs: [])
    |> fetch_plugs()
      |> assign(modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:fuel_usage, :deleted], _}, socket) do
    socket = assign(socket, page: 1, plugs: [])
    socket = fetch_plugs(socket)
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
    %{
      departments: departments,
      types: types,
      yards: yards
    } = socket.assigns
    department = Enum.find(departments, fn x-> x[:key] == cur.data.department end)[:value]
    type = Enum.find(types, fn x-> x[:key] == cur.data.type end)[:value]
    yard = Enum.find(yards, fn x-> x[:key] == cur.data.yard end)[:value]

    socket = assign(socket,
      changeset: cur,
      modal: :change_plug,
      selected_department: department,
      selected_type:       type,
      selected_yard:       yard,
      modal_title: "Edit Fuel Usage")
      |> init_args()
    {:noreply, socket}
  end

  @impl true
  def handle_event("new", _, socket) do
    changeset =
      FuelUsages.new_plug()
      |> FuelUsages.change_plug()
    socket = assign(socket,
      changeset: changeset,
      modal: :change_plug,
      selected_department: 1,
      selected_type:       1,
      selected_yard:       1,
      modal_title: "New Fuel Usage")
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
  def handle_event("edit_types", _, socket) do
    socket = assign(socket,
      modal: :change_type,
      modal_title: "Manage Types")
      |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit_yards", _, socket) do
    socket = assign(socket,
      modal: :change_yard,
      modal_title: "Manage Yards")
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
    FuelUsages.delete_plug(cur.data)
    {:noreply, socket}
  end

  def handle_event("save", %{"fuel_usage" => plug}, socket) do
    %{changeset: changeset, add_more: add_more} = socket.assigns
    changeset = FuelUsages.validate(changeset.data, plug)
    if changeset.valid? do
      case FuelUsages.create_or_update_plug(changeset.data, plug, add_more) do
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

  def handle_event("validate", %{"fuel_usage" => plug}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = FuelUsages.validate(changeset.data, plug)

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
        modal_title: "Fuel Usage Reports")}
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
