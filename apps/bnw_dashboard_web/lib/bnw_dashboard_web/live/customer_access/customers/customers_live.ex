defmodule BnwDashboardWeb.CustomerAccess.Customers.CustomersLive do
  use BnwDashboardWeb, :live_view

  alias BnwDashboardWeb.CustomerAccess.Customers.ChangeCustomerComponent
  alias CustomerAccess.{
    Authorize,
    Customers,
    DataPipeline,
    ReportTypes
  }

  defp fetch_customers(socket) do
    %{page: page, per_page: per_page, search: search} = socket.assigns
    customers = Customers.list_customers(page, per_page, search)
    assign(socket, customers: customers)
  end

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(session, socket)
    |> assign(socket, page_title: "BNW Dashboard · Customers",
                      modal: nil,
                      changeset: nil,
                      app: "Customer Access")
    current_user = Map.get(socket.assigns, :current_user)
    if connected?(socket), do: Customers.subscribe()
    cond do
       current_user && Authorize.authorize(current_user, "customers") ->
        {:ok, socket}
      true ->
        {:ok, redirect(socket, to: "/")}
    end
  end

  @impl true
  def handle_params(%{"change" => change}, _uri, socket) do
    page = Map.get(socket.assigns, :page, 1)
    per_page = Map.get(socket.assigns, :per_page, 20)
    search = Map.get(socket.assigns, :search, "")
    changeset = Customers.get_customer!(change)
    |> Customers.change_customer

    report_types = ReportTypes.list_report_types()
    |> Enum.map(&(%{id: &1.id, name: &1.name, checked: false}))

    socket = assign(socket, update_action: "replace", page: page, per_page: per_page, search: search)
    |> fetch_customers()
    |> assign(modal: :change_customer, changeset: changeset, report_types: report_types)

    if connected?(socket), do: ReportTypes.subscribe()
    {:noreply, socket}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    per_page = 20
    search = ""
    total_pages = Customers.total_pages(per_page, search)
    socket = assign(socket, modal: nil,
                            changeset: nil,
                            update_action: "replace",
                            page: 1,
                            per_page: per_page,
                            search: search,
                            total_pages: total_pages,
                            page_title: "BNW Dashboard · Customers",
                            app: "Customer Access")
    |> fetch_customers()
    {:noreply, socket}
  end

  # handle info
  @impl true
  def handle_info({[:user, :updated], customer}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = cond do
      changeset && changeset.data.id == customer.id ->
        Customers.change_customer(customer)
      true -> changeset
    end
    socket = fetch_customers(socket)
    |> assign(changeset: changeset)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:user, :created], _customer}, socket) do
    {:noreply, fetch_customers(socket)}
  end

  @impl true
  def handle_info({[:user, :deleted], _customer}, socket) do
    {:noreply, fetch_customers(socket)}
  end

  @impl true
  def handle_info({[:customer, :updated], customer}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = cond do
      changeset && changeset.data.id == customer.id ->
        Customers.change_customer(customer)
      true -> changeset
    end
    socket = fetch_customers(socket)
    |> assign(changeset: changeset)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:customer, :created], _customer}, socket) do
    {:noreply, fetch_customers(socket)}
  end

  @impl true
  def handle_info({[:customer, :deleted], _customer}, socket) do
    {:noreply, fetch_customers(socket)}
  end
  # handle info end

  # handle event
  @impl true
  def handle_event("update", _params, socket) do
    DataPipeline.update_customers()
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit", %{"id" => id}, socket) do
    id = String.to_integer(id)
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{change: id}), replace: true)}
  end

  @impl true
  def handle_event("cancel", _params, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__), replace: true)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    customer = Customers.get_customer!(id)
    case Customers.delete_customer(customer) do
      {:ok, _customer} ->
        {:noreply, socket}
      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Could not delete!")}
    end
  end

  @impl true
  def handle_event("load_more", _, socket) do
    %{page: page, per_page: per_page, search: search, total_pages: total_pages} = socket.assigns
    socket = cond do
      page < total_pages ->
        page = page + 1
        customers = Customers.list_customers(page, per_page, search)
        assign(socket, update_action: "append", page: page, customers: customers)
      true -> socket
    end
    {:noreply, socket}
  end

  def handle_event("search_customers", %{"search" => %{"search" => search}}, socket) do
    %{per_page: per_page} = socket.assigns
    total_pages = Customers.total_pages(per_page, search)
    socket = assign(socket, page: 1, search: search, update_action: "replace", total_pages: total_pages)
    |> fetch_customers()
    {:noreply, socket}
  end
  # handle event end
end
