defmodule BnwDashboardWeb.CattlePurchase.Payees.PayeesLive do
  use BnwDashboardWeb, :live_view

  alias CattlePurchase.{
    Payees
  }

  defp fetch_payees(socket) do
    %{page: page, per_page: per_page, search: search} = socket.assigns
    payees = Payees.list_payees(page, per_page, search)
    assign(socket, payees: payees)
  end

  @impl true
  def mount(_params, session, socket) do
    socket =
      assign_defaults(session, socket)
      |> assign(socket, app: "Cattle Purchase",
                        page_title: "BNW Dashboard · Cattle Purchase · Payees")

    if connected?(socket), do: Payees.subscribe()
    {:ok, socket}
  end

  # handle params
  @impl true
  def handle_params(_params, _uri, socket) do
    per_page = 20
    search = ""
    total_pages = Payees.total_pages(per_page, search)
    socket = assign(socket, page: 1,
                            per_page: per_page,
                            search: search,
                            total_pages: total_pages,
                            update_action: "replace",
                            page_title: "BNW Dashboard · Cattle Purchase · Payees",
                            app: "Cattle Purchase")
    |> fetch_payees()
    {:noreply, socket}
  end
  # end handle parsms

  # handle info
  @impl true
  def handle_info({[:payees, :updated], _results}, socket) do
    socket = fetch_payees(socket)
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
    Payees.update_payees()
    {:noreply, socket}
  end

  @impl true
  def handle_event("load_more", _, socket) do
    %{page: page, per_page: per_page, search: search, total_pages: total_pages} = socket.assigns
    socket = cond do
      page < total_pages ->
        page = page + 1
        payees = Payees.list_payees(page, per_page, search)
        assign(socket, update_action: "append", page: page, payees: payees)
      true -> socket
    end
    {:noreply, socket}
  end

  @impl true
  def handle_event("search_payees", %{"search" => %{"search" => search}}, socket) do
    %{per_page: per_page} = socket.assigns
    total_pages = Payees.total_pages(per_page, search)
    socket = assign(socket, page: 1, search: search, update_action: "replace", total_pages: total_pages)
    |> fetch_payees()
    {:noreply, socket}
  end

  # end handle event
end
