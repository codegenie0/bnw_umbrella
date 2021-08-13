defmodule BnwDashboardWeb.CattlePurchase.CattleReceive.CattleReceiveLive do
  use BnwDashboardWeb, :live_view

  alias CattlePurchase.{
    Authorize,
    Purchases,
    Purchase,
    Shipment,
    CattleReceive,
    CattleReceivings,
    Sexes,
    Repo
  }

  alias BnwDashboardWeb.CattlePurchase.CattleReceive.ChangeCattleReceiveComponent

  defp authenticate(socket) do
    current_user = Map.get(socket.assigns, :current_user)

    cond do
      current_user && Authorize.authorize(current_user, "cattle_receives") ->
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
      "Firm"
    ]

    {id, ""} = Integer.parse(params["id"])
    shipment = Repo.get(Shipment, id)

    purchase =
      Repo.get(Purchase, shipment.purchase_id)
      |> Repo.preload([:sex, :purchase_buyer, :destination_group])

    cattle_receives = CattleReceivings.get_cattle_receivings(shipment.id)

    socket =
      assign_defaults(session, socket)
      |> assign(
        page_title: "Cattle Receive",
        app: "Cattle Purchase",
        purchase: purchase,
        shipment: shipment,
        cattle_receives: cattle_receives,
        sort_columns: sort_columns,
        modal: nil
      )

    if connected?(socket) do
      CattleReceivings.subscribe()
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
