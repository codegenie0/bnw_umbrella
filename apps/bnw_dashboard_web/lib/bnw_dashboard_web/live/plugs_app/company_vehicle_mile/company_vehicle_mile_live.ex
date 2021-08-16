defmodule BnwDashboardWeb.PlugsApp.CompanyVehicleMile.CompanyVehicleMileLive do

  use BnwDashboardWeb, :live_view

  alias BnwDashboardWeb.PlugsApp.Helpers.{
    ModalComponent,
    TableLive,
    SearchLive,
    ChangeReportComponent
  }
  alias BnwDashboardWeb.PlugsApp.CompanyVehicleMile.{
    ChangeFiscalYearComponent,
    ChangeYardComponent
  }
  alias PlugsApp.{
    CompanyVehicleMiles,
    CompanyVehicleMileFiscalYears,
    CompanyVehicleMileYards,
    Authorize,
    Reports,
    Users
  }

  defp get_role(socket) do
    current_user = Map.get(socket.assigns, :current_user)
    if current_user do
      Authorize.authorize(current_user, "vehicle_miles")
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
      selected_yard: selected_yard,
      selected_fiscal_year: selected_fiscal_year,
      yards: yards,
      fiscal_years: fiscal_years
    } = socket.assigns

    args = [
      %{type: :date,      special: nil,     name: :entry_date,  display_name: "Date"},
      %{type: :drop_down, special: nil,     name: :fy,          display_name: "FY", selected: selected_fiscal_year, list: fiscal_years},
      %{type: :drop_down, special: nil,     name: :yard,        display_name: "Yard", selected: selected_yard, list: yards},
      %{type: :text,      special: nil,     name: :driver_name, display_name: "Name"},
      %{type: :number,    special: :int,    name: :beginning,   display_name: "Beginning", step: 1},
      %{type: :number,    special: :int,    name: :ending,      display_name: "Ending", step: 1},
      %{type: :read_only, special: :int,    name: :miles,       display_name: "Miles", step: 1},
      %{type: :number,    special: :int,    name: :trip_miles,  display_name: "Trip Miles", step: 1},
    ]

    assign(socket, args: args)
  end

  defp fetch_items(plug) do
    fy = Map.get(plug, :fy, 0)
    |> CompanyVehicleMileFiscalYears.get_plug()

    yard = Map.get(plug, :yard, 0)
    |> CompanyVehicleMileYards.get_plug()

    Map.put(plug, :fy, fy)
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
      CompanyVehicleMiles.list_plugs(page, per_page, search_col, search)
      |> Enum.map(&(fetch_items(&1)))
      |> Enum.map(&(CompanyVehicleMiles.change_plug(&1)))
    assign(socket, plugs: pre_plugs ++ plugs)
  end

  defp fetch_extra(socket) do
    yards = CompanyVehicleMileYards.list_plugs()
    years = CompanyVehicleMileFiscalYears.list_plugs()
    assign(socket, yards: yards, fiscal_years: years)
  end

  defp fetch_plug_extra(socket) do
    plug_yards = CompanyVehicleMileYards.list_all_plugs()
    plug_years = CompanyVehicleMileFiscalYears.list_all_plugs()
    assign(socket, plug_yards: plug_yards, plug_fiscal_years: plug_years)
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
      |> assign(page_title: "BNW Dashboard · Plugs Company Vehicle Miles",
                app: "Plugs",
                add_more: false,
                selected_yard: nil,
                selected_fiscal_year: nil,
                modal: nil,
                update_action: "replace",
                page: page,
                plug: "company_vehicle_mile",
                selected_search_col: :entry_date,
                search: "",
                per_page: per_page)
      |> fetch_plugs()
      |> fetch_extra()
      |> fetch_permissions()
      |> init_args()
      |> init_reports()

    if connected?(socket) do
      Users.subscribe()
      CompanyVehicleMiles.subscribe()
      CompanyVehicleMileFiscalYears.subscribe()
      CompanyVehicleMileYards.subscribe()
      Reports.subscribe()
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
  def handle_info({[:company_vehicle_mile, :created_or_updated], _}, socket) do
    socket = assign(socket, page: 1, plugs: [])
    |> fetch_plugs()
      |> assign(modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:company_vehicle_mile, :created_or_updated_add_more], _}, socket) do
    changeset =
      CompanyVehicleMiles.new_plug()
      |> CompanyVehicleMiles.change_plug
    cur_date = Date.utc_today()
    socket = assign(socket,
      changeset: changeset,
      modal: :change_plug,
      modal_title: "New Company Vehicle Miles",
      selected_yard: 1,
      selected_fiscal_year: CompanyVehicleMileFiscalYears.get_plug_by_year(cur_date))
    |> assign(page: 1, plugs: [])
    |> fetch_plugs()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:company_vehicle_mile, :deleted], _}, socket) do
    socket = assign(socket, page: 1, plugs: [])
    |> fetch_plugs()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:company_vehicle_mile_yard, :created_or_updated], _}, socket) do
    socket = fetch_extra(socket)
      |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:company_vehicle_mile_yard, :deleted], _}, socket) do
    socket = fetch_extra(socket)
    |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:company_vehicle_mile_fiscal_year, :created_or_updated], _}, socket) do
    socket = fetch_extra(socket)
    |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:company_vehicle_mile_fiscal_year, :deleted], _}, socket) do
    socket = fetch_extra(socket)
    |> fetch_plug_extra()
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
      yards: yards,
      fiscal_years: fiscal_years
    } = socket.assigns
    yard = Enum.find(yards, fn x-> x[:key] == cur.data.yard end)[:value]
    year = Enum.find(fiscal_years, fn x-> x[:key] == cur.data.fy end)[:value]

    socket = assign(socket,
      changeset: cur,
      modal: :change_plug,
      modal_title: "Edit Company Vehicle  Miles",
      selected_yard: yard,
      selected_fiscal_year: year)
    |> init_args()
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
  def handle_event("edit_fiscal_years", _, socket) do
    socket = assign(socket,
      modal: :change_fiscal_year,
      modal_title: "Manage Fiscal Years")
      |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_event("new", _, socket) do
    changeset =
      CompanyVehicleMiles.new_plug()
      |> CompanyVehicleMiles.change_plug
    cur_date = Date.utc_today()
    socket = assign(socket,
      changeset: changeset,
      modal: :change_plug,
      modal_title: "New Company Vehicle Miles",
      selected_yard: 1,
      selected_fiscal_year: CompanyVehicleMileFiscalYears.get_plug_by_year(cur_date))
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
    CompanyVehicleMiles.delete_plug(cur.data)
    {:noreply, socket}
  end

  def handle_event("save", %{"company_vehicle_mile" => plug}, socket) do
    %{changeset: changeset, add_more: add_more} = socket.assigns

    changeset = CompanyVehicleMiles.validate(changeset.data, plug)
    if changeset.valid? do
      case CompanyVehicleMiles.create_or_update_plug(changeset.data, plug, add_more) do
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

  def handle_event("validate", %{"company_vehicle_mile" => plug}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = CompanyVehicleMiles.validate(changeset.data, plug)

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
        modal_title: "Company Vehicle Mile Reports")}
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
