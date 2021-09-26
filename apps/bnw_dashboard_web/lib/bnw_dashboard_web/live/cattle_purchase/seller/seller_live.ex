defmodule BnwDashboardWeb.CattlePurchase.Seller.SellerLive do
  use BnwDashboardWeb, :live_view

  alias CattlePurchase.{
    Authorize,
    Sellers,
    States
  }

  alias BnwDashboardWeb.CattlePurchase.Sellers.ChangeSellerComponent

  defp authenticate(socket) do
    current_user = Map.get(socket.assigns, :current_user)

    cond do
      current_user && Authorize.authorize(current_user, "sellers") ->
        true

      true ->
        false
    end
  end

  @impl true
  def mount(_, session, socket) do
    socket =
      assign_defaults(session, socket)
      |> assign(
        page_title: "Seller",
        app: "Cattle Purchase",
        modal: nil,
        sellers: Sellers.get_active_sellers(),
        seller: "active"
      )

    if connected?(socket) do
      Sellers.subscribe()
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
  def handle_event("new", _, socket) do
    changeset = Sellers.new_seller()

    socket =
      assign(socket,
        changeset: changeset,
        modal: :change_seller,
        states: States.get_active_states()
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("edit", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    seller = Enum.find(socket.assigns.sellers, fn sh -> sh.id == id end)

    changeset =
      seller
      |> Sellers.change_seller()

    states = States.get_active_states()

    socket =
      assign(socket,
        changeset: changeset,
        modal: :change_seller,
        states: Enum.map(states, &%{id: &1.id, name: &1.name})
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", params, socket) do
    {id, ""} = Integer.parse(params["id"])

    Enum.find(socket.assigns.sellers, fn pg -> pg.id == id end)
    |> Sellers.delete_seller()

    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_event("set-active-seller", _params, socket) do
    {:noreply,
     assign(socket,
       seller: "active",
       page_title: "Active Seller",
       sellers: Sellers.get_active_sellers()
     )}
  end

  @impl true
  def handle_event("set-inactive-seller", _params, socket) do
    {:noreply,
     assign(socket,
       seller: "inactive",
       page_title: "Inactive Seller",
       sellers: Sellers.get_inactive_sellers()
     )}
  end

  @impl true
  def handle_event("search", %{"search_seller" => %{"query" => query}}, socket) do
    {:noreply, assign(socket, sellers: Sellers.search_query(query))}
  end

  @impl true
  def handle_info({[:sellers, :created_or_updated], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
    seller = socket.assigns.seller
    data = fetch_by_type(seller)
    {:noreply, assign(socket, sellers: data)}
  end

  @impl true
  def handle_info({[:sellers, :deleted], _}, socket) do
    seller = socket.assigns.seller
    data = fetch_by_type(seller)
    {:noreply, assign(socket, sellers: data)}
  end

  defp fetch_by_type(seller) do
    if seller == "active",
      do: Sellers.get_active_sellers(),
      else: Sellers.get_inactive_sellers()
  end
end
