defmodule BnwDashboardWeb.CattlePurchase.PurchaseBuyer.PurchaseBuyerLive do
  use BnwDashboardWeb, :live_view
  alias CattlePurchase.{
    Authorize,
    PurchaseBuyers
  }
  # alias BnwDashboardWeb.CattlePurchase.PurchaseBuyers.ChangePurchaseBuyerComponent

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
  def handle_event("sort-up", _params, socket) do
    {:noreply, assign(socket, purchase_buyers: PurchaseBuyers.sort_by("asc") )}
  end

  @impl true
  def handle_event("sort-down", _params, socket) do
    {:noreply, assign(socket, purchase_buyers: PurchaseBuyers.sort_by("desc") )}
  end
end
