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
  alias BnwDashboardWeb.CattlePurchase.CattleReceive.CattleReceiveLive

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

  @impl true
  def handle_info({[:shipments, :deleted], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
    {:noreply, assign(socket, shipments: Shipments.get_shipments(socket.assigns.purchase.id))}
  end

  @impl true
  def handle_info({[:shipments, :created_or_updated], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
    {:noreply, assign(socket, shipments: Shipments.get_shipments(socket.assigns.purchase.id))}
  end

  @impl true
  def handle_event("new", _, socket) do
    changeset = Shipments.new_shipment()

    socket =
      assign(socket,
        changeset: changeset,
        modal: :change_purchase_shipment,
        destinations: Purchases.get_destination("") |> format_destination_group(),
        sexes: Sexes.get_active_sexes()
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("edit", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    shipment = Enum.find(socket.assigns.shipments, fn sh -> sh.id == id end)

    changeset =
      shipment
      |> Shipments.change_shipment()

    destination_groups = Purchases.get_destination("") |> format_destination_group()
    sexes = Sexes.get_active_sexes()

    result = modify_destination_group_for_select(shipment)

    changeset =
      Ecto.Changeset.put_change(changeset, :destination_group_id, result)
      |> Map.put(:action, :update)

    socket =
      assign(socket,
        changeset: changeset,
        modal: :change_purchase_shipment,
        sexes: Enum.map(sexes, &%{id: &1.id, name: &1.name}),
        destinations: destination_groups
      )

    {:noreply, socket}
  end

  defp format_destination_group(destination_groups) do
    Enum.reduce(destination_groups, [], fn destination_group, acc ->
      acc = acc ++ [%{id: destination_group.id, name: destination_group.name, child: false}]

      small =
        Enum.map(destination_group.destinations, fn item ->
          %{name: item.name, id: destination_group.id, child: true}
        end)

      acc = acc ++ small
    end)
  end

  defp modify_destination_group_for_select(shipment) do
    cond do
      !shipment.destination_group_name ->
        ""

      String.contains?(shipment.destination_group_name, ">") ->
        [parent_name, child_name] =
          String.split(shipment.destination_group_name, ">")
          |> Enum.map(fn item -> String.trim(item) end)

        Integer.to_string(shipment.destination_group_id) <>
          "|" <> child_name

      shipment.destination_group_name == "" ->
        Integer.to_string(shipment.destination_group_id)

      true ->
        Integer.to_string(shipment.destination_group_id)
    end
  end

  @impl true
  def handle_event("delete", params, socket) do
    {id, ""} = Integer.parse(params["id"])

    Enum.find(socket.assigns.shipments, fn sh -> sh.id == id end)
    |> Shipments.delete_shipment()

    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, modal: nil)
    {:noreply, socket}
  end
end
