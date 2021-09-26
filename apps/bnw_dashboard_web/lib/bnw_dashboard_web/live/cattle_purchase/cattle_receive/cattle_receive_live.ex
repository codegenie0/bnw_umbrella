defmodule BnwDashboardWeb.CattlePurchase.CattleReceive.CattleReceiveLive do
  use BnwDashboardWeb, :live_view

  alias CattlePurchase.{
    Authorize,
    Purchase,
    Shipment,
    CattleReceivings,
    Sexes,
    Repo
  }

  alias BnwDashboardWeb.CattlePurchase.CattleReceive.ChangeCattleReceiveComponent
  alias BnwDashboardWeb.CattlePurchase.Purchase.PurchaseLive

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
      "Purchase Order",
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
      |> Repo.preload([:purchase_buyer, :destination_group])

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

  @impl true
  def handle_info({[:cattle_receivings, :deleted], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)

    {:noreply,
     assign(socket,
       cattle_receives: CattleReceivings.get_cattle_receivings(socket.assigns.shipment.id)
     )}
  end

  @impl true
  def handle_info({[:cattle_receivings, :created_or_updated], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)

    {:noreply,
     assign(socket,
       cattle_receives: CattleReceivings.get_cattle_receivings(socket.assigns.shipment.id)
     )}
  end

  @impl true
  def handle_event("new", _, socket) do
    changeset = CattleReceivings.new_cattle_receiving()

    socket =
      assign(socket,
        changeset: changeset,
        modal: :change_cattle_receive,
        sexes: Sexes.get_active_sexes()
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("edit", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    cattle_receive = Enum.find(socket.assigns.cattle_receives, fn sh -> sh.id == id end)

    changeset =
      cattle_receive
      |> CattleReceivings.change_cattle_receiving()

    sexes = Sexes.get_active_sexes()

    socket =
      assign(socket,
        changeset: changeset,
        modal: :change_cattle_receive,
        sexes: Enum.map(sexes, &%{id: &1.id, name: &1.name})
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", params, socket) do
    {id, ""} = Integer.parse(params["id"])

    Enum.find(socket.assigns.cattle_receives, fn sh -> sh.id == id end)
    |> CattleReceivings.delete_cattle_receiving()

    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, modal: nil)
    {:noreply, socket}
  end
end
