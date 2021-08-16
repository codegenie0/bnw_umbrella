defmodule BnwDashboardWeb.PlugsApp.OutsideBilling.OutsideBillingLive do

  use BnwDashboardWeb, :live_view

  alias BnwDashboardWeb.PlugsApp.Helpers.{
    ModalComponent,
    TableLive,
    SearchLive,
    ChangeReportComponent
  }
  alias BnwDashboardWeb.PlugsApp.OutsideBilling.ChangeCustomerComponent
  alias BnwDashboardWeb.PlugsApp.OutsideBilling.ChangeLocationComponent
  alias BnwDashboardWeb.PlugsApp.OutsideBilling.ChangeServiceTypeComponent
  alias PlugsApp.{
    OutsideBillings,
    OutsideBillingCustomers,
    OutsideBillingLocations,
    OutsideBillingServiceTypes,
    Authorize,
    Reports,
    Users
  }

  defp get_role(socket) do
    current_user = Map.get(socket.assigns, :current_user)
    if current_user do
      Authorize.authorize(current_user, "outside_billing")
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
      selected_customer: selected_customer,
      customers: customers,
      selected_location: selected_location,
      locations: locations,
      selected_service_type: selected_service_type,
      service_types: service_types
    } = socket.assigns

    args = [
      %{type: :date,      special: nil,       name: :service_date, display_name: "Service Date"},
      %{type: :drop_down, special: nil,       name: :customer,     display_name: "Customer", selected: selected_customer, list: customers},
      %{type: :drop_down, special: nil,       name: :location,     display_name: "Location", selected: selected_location, list: locations},
      %{type: :number,    special: nil,       name: :quantity,     display_name: "Quantity", step: 0.1},
      %{type: :number,    special: :currency, name: :price,        display_name: "Price", step: 0.01},
      %{type: :check_box, special: :nil,      name: :no_charge,    display_name: "No Charge"},
      %{type: :check_box, special: :nil,      name: :pass_thru,    display_name: "Pass Thru"},
      %{type: :text,      special: :nil,      name: :comments,     display_name: "Comments"},
      %{type: :drop_down, special: nil,       name: :service_type, display_name: "Service_Type", selected: selected_service_type, list: service_types},
    ]

    assign(socket, args: args)
  end

  defp fetch_items(plug) do
    location = Map.get(plug, :location, 0)
    |> OutsideBillingLocations.get_plug()

    service_type = Map.get(plug, :service_type, 0)
    |> OutsideBillingServiceTypes.get_plug()

    customer = Map.get(plug, :location, 0)
    |> OutsideBillingLocations.get_customer()
    |> OutsideBillingCustomers.get_plug()

    Map.put(plug, :location, location)
    |> Map.put(:customer, customer)
    |> Map.put(:service_type, service_type)
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
      OutsideBillings.list_plugs(page, per_page, search_col, search)
      |> Enum.map(&(fetch_items(&1)))
      |> Enum.map(&(OutsideBillings.change_plug(&1)))
    assign(socket, plugs: pre_plugs ++ plugs)
  end

  defp fetch_extra(socket) do
    customers     = OutsideBillingCustomers.list_plugs()
    locations     = OutsideBillingLocations.list_plugs()
    service_types = OutsideBillingServiceTypes.list_plugs()
    assign(socket,
      customers:     customers,
      locations:     locations,
      service_types: service_types
    )
  end

  defp fetch_plug_extra(socket) do
    plug_customers     = OutsideBillingCustomers.list_all_plugs()
    plug_locations     = OutsideBillingLocations.list_all_plugs()
    plug_service_types = OutsideBillingServiceTypes.list_all_plugs()
    assign(socket,
      plug_customers:     plug_customers,
      plug_locations:     plug_locations,
      plug_service_types: plug_service_types
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
      |> assign(page_title: "BNW Dashboard · Plugs Outside Billing",
                app: "Plugs",
                add_more: false,
                selected_customer: nil,
                selected_location: nil,
                selected_service_type: nil,
                customers: nil,
                modal: nil,
                update_action: "replace",
                selected_search_col: :service_date,
                search: "",
                page: page,
                plug: "outside_billing",
                per_page: per_page)
      |> fetch_plugs()
      |> fetch_extra()
      |> fetch_permissions()
      |> init_args()
      |> init_reports()

    if connected?(socket) do
      OutsideBillings.subscribe()
      OutsideBillingCustomers.subscribe()
      OutsideBillingLocations.subscribe()
      OutsideBillingServiceTypes.subscribe()
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
  def handle_info({[:outside_billing_customer, :created_or_updated], _}, socket) do
    socket = fetch_extra(socket)
    |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:outside_billing_customer, :deleted], _}, socket) do
    socket = fetch_extra(socket)
    |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:outside_billing_location, :created_or_updated], _}, socket) do
    socket = fetch_extra(socket)
    |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:outside_billing_location, :deleted], _}, socket) do
    socket = fetch_extra(socket)
    |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:outside_billing_service_type, :created_or_updated], _}, socket) do
    socket = fetch_extra(socket)
    |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:outside_billing_service_type, :deleted], _}, socket) do
    socket = fetch_extra(socket)
    |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:outside_billing, :created_or_updated_add_more], _}, socket) do
    changeset =
      OutsideBillings.new_plug()
      |> OutsideBillings.change_plug()

    %{customers: customers} = socket.assigns
    customer = Enum.at(customers, 0)[:value]

    locations = OutsideBillingLocations.list_plugs(customer)


    socket = assign(socket,
      changeset: changeset,
      modal: :change_plug,
      modal_title: "New Outside Billing",
      selected_customer: customer,
      selected_location: 1,
      locations: locations,
      selected_service_type: 1)
    |> assign(page: 1, plugs: [])
    |> fetch_plugs()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:outside_billing, :created_or_updated], _}, socket) do
    socket = assign(socket, page: 1, plugs: [])
    |> fetch_plugs()
      |> assign(modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:outside_billing, :deleted], _}, socket) do
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
  def handle_event("edit_customers", _, socket) do
    socket = assign(socket,
      modal: :change_customer,
      modal_title: "Manage Customers")
      |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit_service_types", _, socket) do
    socket = assign(socket,
      modal: :change_service_type,
      modal_title: "Manage Service Types")
      |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit_locations", _, socket) do
    socket = assign(socket,
      modal: :change_location,
      modal_title: "Manage Locations")
      |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    cur = Enum.find(socket.assigns.plugs, fn u -> u.data.id == id end)
    %{
      customers: customers,
      locations: locations,
      service_types: service_types
    } = socket.assigns
    customer     = Enum.find(customers, fn x-> x[:key]     == cur.data.customer end)[:value]
    location     = Enum.find(locations, fn x-> x[:key]     == cur.data.location end)[:value]
    service_type = Enum.find(service_types, fn x-> x[:key] == cur.data.service_type end)[:value]

    socket = assign(socket,
      changeset: cur,
      modal: :change_plug,
      modal_title: "Edit Outside Billing",
      selected_customer: customer,
      selected_location: location,
      selected_service_type: service_type)
      |> init_args()
    {:noreply, socket}
  end

  @impl true
  def handle_event("new", _, socket) do
    changeset =
      OutsideBillings.new_plug()
      |> OutsideBillings.change_plug()

    %{customers: customers} = socket.assigns
    customer = Enum.at(customers, 0)[:value]

    locations = OutsideBillingLocations.list_plugs(customer)


    socket = assign(socket,
      changeset: changeset,
      modal: :change_plug,
      modal_title: "New Outside Billing",
      selected_customer: customer,
      selected_location: 1,
      locations: locations,
      selected_service_type: 1)
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
    OutsideBillings.delete_plug(cur.data)
    {:noreply, socket}
  end

  def handle_event("save", %{"outside_billing" => plug}, socket) do
    %{changeset: changeset, add_more: add_more} = socket.assigns

    changeset = OutsideBillings.validate(changeset.data, plug)
    if changeset.valid? do
      case OutsideBillings.create_or_update_plug(changeset.data, plug, add_more) do
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

  def handle_event("validate", %{"outside_billing" => plug}, socket) do
    %{changeset: changeset} = socket.assigns

    customer =
      cond do
      Map.has_key?(plug, "customer")             -> Map.get(plug, "customer")
      Map.has_key?(changeset.changes, :customer) -> Map.get(changeset.changes, :customer)
      Map.has_key?(changeset.data, :customer)    -> Map.get(changeset.data, :customer)
      true -> 0
    end
    locations = OutsideBillingLocations.list_plugs(customer)

    changeset = OutsideBillings.validate(changeset.data, plug)

    socket = assign(socket,
      changeset: changeset,
      locations: locations)
    |> init_args()
    {:noreply, socket}
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
        modal_title: "Outside Billing Reports")}
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

    search = if search_col == :no_charge || search_col == :pass_thru  do
      if search == "true", do: 1, else: 0
    else
      search
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
