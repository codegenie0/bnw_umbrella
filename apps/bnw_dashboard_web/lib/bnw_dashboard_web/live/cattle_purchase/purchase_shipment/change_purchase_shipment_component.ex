defmodule BnwDashboardWeb.CattlePurchase.PurchaseShipment.ChangePurchaseShipmentComponent do
  @moduledoc """
  ### Live view component for the add/update purchase shipment modal.
  """
  use BnwDashboardWeb, :live_component
  import Ecto.Changeset

  alias CattlePurchase.{
    Purchases,
    Purchase,
    Shipments,
    Sexes,
    Repo
  }

  alias BnwDashboardWeb.CattlePurchase.PurchaseShipment.PurchaseShipmentLive

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"shipment" => shipment} = params, socket) do
    purchase_id = shipment["purchase_id"] |> String.to_integer()
    purchase = Repo.get(Purchase, purchase_id)
    socket = assign(socket, :shipment_form_data, shipment)
    %{changesets: changesets} = socket.assigns
    changeset = List.last(changesets)

    changeset =
      if shipment["head_count"] != "" do
        if purchase.head_count != shipment["head_count"] |> String.to_integer() do
          add_error(changeset, :head_count, "Must be equal to the head_count of purchases")
        else
          changeset
        end
      else
        add_error(changeset, :head_count, "head count is blank")
      end

    %{id: id, name: name} = extract_data_from_destination(shipment["destination_group_id"])

    parent_destination =
      Enum.find(socket.assigns.destinations, %{id: "", name: ""}, fn item ->
        if(String.trim(id) == "") do
          item.id == id && !item.child
        else
          item.id == String.to_integer(id) && !item.child
        end
      end)

    shipment = Map.put(shipment, "destination_group_id", id)

    shipment =
      Map.put(
        shipment,
        "destination_group_name",
        "#{parent_destination.name}#{if name == "", do: "", else: " > #{name}"}"
      )

    changeset = Shipments.validate(changeset.data, shipment)

    if changeset.valid? do
      case Shipments.create_or_update_shipment(changeset.data, shipment) do
        {:ok, _purchase} ->
          {:noreply,
           push_patch(socket,
             to: Routes.live_path(socket, PurchaseShipmentLive, id: socket.assigns.purchase.id)
           )}

        {:error, %Ecto.Changeset{} = changest} ->
          result = if name == "", do: id, else: "#{id}|#{name}"
          changeset = Ecto.Changeset.put_change(changeset, :destination_group_id, result)
          changesets = List.replace_at(changesets, length(changesets) - 1, changeset)
          {:noreply, assign(socket, changesets: changesets)}
      end
    else
      result = if name == "", do: id, else: "#{id}|#{name}"
      changeset = Ecto.Changeset.put_change(changeset, :destination_group_id, result)
      changesets = List.replace_at(changesets, length(changesets) - 1, changeset)
      {:noreply, assign(socket, changesets: changesets)}
    end
  end

  def handle_event("validate", %{"shipment" => shipment}, socket) do
    %{id: id, name: name} = extract_data_from_destination(shipment["destination_group_id"])
    %{changesets: changesets} = socket.assigns
    socket = assign(socket, :shipment_form_data, shipment)

    parent_destination =
      Enum.find(socket.assigns.destinations, %{id: "", name: ""}, fn item ->
        if(String.trim(id) == "") do
          item.id == id && !item.child
        else
          item.id == String.to_integer(id) && !item.child
        end
      end)

    shipment = Map.put(shipment, "destination_group_id", id)

    %{changesets: changesets} = socket.assigns
    changeset = List.last(changesets)

    changeset =
      changeset.data
      |> Shipments.change_shipment(shipment)
      |> Map.put(:action, :update)

    result = if name == "", do: id, else: "#{id}|#{name}"
    changeset = Ecto.Changeset.put_change(changeset, :destination_group_id, result)

    changesets = List.replace_at(changesets, length(changesets) - 1, changeset)
    {:noreply, assign(socket, changesets: changesets)}
  end

  def handle_event("add-more-shipment", _params, socket) do
    shipment = socket.assigns.shipment_form_data
    %{changesets: changesets} = socket.assigns
    changeset = List.last(changesets)
    purchase = socket.assigns.purchase

    changeset =
      if shipment["head_count"] != "" do
        if purchase.head_count != shipment["head_count"] |> String.to_integer() do
          add_error(changeset, :head_count, "Must be equal to the head_count of purchases")
        else
          changeset
        end
      else
        add_error(changeset, :head_count, "head count is blank")
      end

    %{id: id, name: name} = extract_data_from_destination(shipment["destination_group_id"])

    parent_destination =
      Enum.find(socket.assigns.destinations, %{id: "", name: ""}, fn item ->
        if(String.trim(id) == "") do
          item.id == id && !item.child
        else
          item.id == String.to_integer(id) && !item.child
        end
      end)

    shipment = Map.put(shipment, "destination_group_id", id)

    shipment =
      Map.put(
        shipment,
        "destination_group_name",
        "#{parent_destination.name}#{if name == "", do: "", else: " > #{name}"}"
      )

    # changeset = Shipments.validate(changeset.data, shipment)
    changeset =
      changeset.data
      |> Shipments.change_shipment(shipment)
      |> Map.put(:action, :update)

    # changeset = Map.put(changeset, :action, :update)
    changesets = List.replace_at(changesets, length(changesets) - 1, changeset)

    if changeset.valid? do
      changesets = changesets ++ [Shipments.new_shipment() |> Map.put(:action, :update)]
      {:noreply, assign(socket, changesets: changesets, add_feedback: false)}
    else
      {:noreply, assign(socket, changesets: changesets, add_feedback: true)}
    end
  end

  defp extract_data_from_destination(data) do
    if String.contains?(data, "|") do
      [id, name] = String.split(data, "|")
      %{id: id, name: name}
    else
      %{id: data, name: ""}
    end
  end
end
