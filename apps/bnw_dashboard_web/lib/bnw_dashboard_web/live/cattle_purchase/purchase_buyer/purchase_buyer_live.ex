defmodule BnwDashboardWeb.CattlePurchase.PurchaseBuyer.PurchaseBuyerLive do
  use BnwDashboardWeb, :live_view

  alias CattlePurchase.{
    Authorize,
    PurchaseBuyers
  }
  alias BnwDashboardWeb.CattlePurchase.PurchaseBuyers.ChangePurchaseBuyerComponent

  defp authenticate(socket) do
    current_user = Map.get(socket.assigns, :current_user)

    cond do
      current_user && Authorize.authorize(current_user, "purchase_buyers") ->
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
        page_title: "BNW Dashboard · Purchase Buyer",
        app: "Cattle Purchase",
        purchase_buyers: PurchaseBuyers.list_purchase_buyers(),
        modal: nil
      )

    if connected?(socket) do
      PurchaseBuyers.subscribe()
    end

    case authenticate(socket) do
      true -> {:ok, socket}
      false -> {:ok, redirect(socket, to: "/")}
    end
  end

  @impl true
  def handle_params(_,_, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("new", _, socket) do
    changeset = PurchaseBuyers.new_purchase_buyer()
    socket = assign(socket, changeset: changeset, modal: :change_purchase_buyer)
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    changeset =
          Enum.find(socket.assigns.purchase_buyers, fn pg -> pg.id == id end )
          |>PurchaseBuyers.change_purchase_buyer()
    socket = assign(socket, changeset: changeset, modal: :change_purchase_buyer)
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    Enum.find(socket.assigns.purchase_buyers, fn pg -> pg.id == id end )
    |>PurchaseBuyers.delete_purchase_buyer()
    {:noreply, socket}
  end

  @impl true
  def handle_event("sort-up", params, socket) do
    {:noreply, assign(socket, purchase_buyers: PurchaseBuyers.sort_by("asc") )}
  end

  @impl true
  def handle_event("sort-down", params, socket) do
    {:noreply, assign(socket, purchase_buyers: PurchaseBuyers.sort_by("desc") )}
  end

  @impl true
  def handle_info({[:purchase_buyers, :created_or_updated], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
    {:noreply, assign(socket, purchase_buyers: PurchaseBuyers.list_purchase_buyers() )}
  end

  @impl true
  def handle_info({[:purchase_buyers, :deleted], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
    {:noreply, assign(socket, purchase_buyers: PurchaseBuyers.list_purchase_buyers() )}
  end

  @impl true
  def handle_event("search", %{"search_buyer" => %{"query" => query}}, socket) do
    {:noreply, assign(socket, purchase_buyers: PurchaseBuyers.search_query(query) )}
  end
end
