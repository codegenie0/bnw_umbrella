defmodule BnwDashboardWeb.CattlePurchase.PurchaseShipment.PurchaseShipmentLive do
  use BnwDashboardWeb, :live_view

  alias CattlePurchase.{
    Authorize,
    Purchases,
    Purchase,
    Shipments,
    Sexes,
    Repo
  }

  alias BnwDashboardWeb.CattlePurchase.PurchaseShipment.ChangePurchaseShipmentComponent

  defp authenticate(socket) do
    current_user = Map.get(socket.assigns, :current_user)

    cond do
      current_user && Authorize.authorize(current_user, "purchases") ->
        true

      true ->
        false
    end
  end

  @impl true
  def mount(params, session, socket) do
    sort_columns = [
      "Purchase Date",
      "Seller",
      "Purchase Location",
      "Purchase Order",
      "Head Count",
      "Sex",
      "Weight",
      "Price",
      "Delivered Price",
      "Delivered",
      "Buyer",
      "Destination",
      "Ship Date",
      "Firm",
      "Kill Date"
    ]

    {id, ""} = Integer.parse(params["id"])
    purchase = Repo.get(Purchase, id) |> Repo.preload([:sex, :purchase_buyer, :destination_group])

    socket =
      assign_defaults(session, socket)
      |> assign(
        page_title: "Purchase Shipments",
        app: "Cattle Purchase",
        purchase: purchase,
        shipments: Shipments.get_shipments(id),
        sort_columns: sort_columns,
        modal: nil
      )

    if connected?(socket) do
      Shipments.subscribe()
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
end
