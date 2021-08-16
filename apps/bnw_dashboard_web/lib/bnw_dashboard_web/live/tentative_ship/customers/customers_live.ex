defmodule BnwDashboardWeb.TentativeShip.Customers.CustomersLive do
  use BnwDashboardWeb, :live_view

  alias TentativeShip.{
    Customers
  }

  defp fetch_customers(socket) do
    %{page: page, per_page: per_page, search: search} = socket.assigns
    customers = Customers.list_customers(page, per_page, search)
    assign(socket, customers: customers)
  end

  @impl true
  def mount(_params, session, socket) do
    socket =
      assign_defaults(session, socket)
      |> assign(socket, app: "Tentative Shipments",
                        page_title: "BNW Dashboard · Tentative Ship · Customers")

    if connected?(socket), do: Customers.subscribe()
    {:ok, socket}
  end

  # handle params
  @impl true
  def handle_params(_params, _uri, socket) do
    per_page = 20
    search = ""
    total_pages = Customers.total_pages(per_page, search)
    socket = assign(socket, page: 1,
                            per_page: per_page,
                            search: search,
                            total_pages: total_pages,
                            update_action: "replace",
                            page_title: "BNW Dashboard · Tentative Ship · Customers",
                            app: "Tentative Shipments")
    |> fetch_customers()
    {:noreply, socket}
  end
  # end handle parsms

  # handle info
  @impl true
  def handle_info({[:customers, :updated], _results}, socket) do
    socket = fetch_customers(socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end
  # end handle info

  # handle event
  @impl true
  def handle_event("update", _params, socket) do
    Customers.update_customers()
    {:noreply, socket}
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

  @impl true
  def handle_event("search_customers", %{"search" => %{"search" => search}}, socket) do
    %{per_page: per_page} = socket.assigns
    total_pages = Customers.total_pages(per_page, search)
    socket = assign(socket, page: 1, search: search, update_action: "replace", total_pages: total_pages)
    |> fetch_customers()
    {:noreply, socket}
  end

  # end handle event
end
