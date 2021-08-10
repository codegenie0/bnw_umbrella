defmodule BnwDashboardWeb.CattlePurchase.PurchaseShipment.ChangePurchaseShipmentComponent do
  @moduledoc """
  ### Live view component for the add/update purchase modal.
  """
  use BnwDashboardWeb, :live_component
  alias CattlePurchase.{
    Purchases,
    Shipments,
    Sexes,
    Repo
  }
  alias BnwDashboardWeb.CattlePurchase.PurchaseShipment.PurchaseShipmentLive
  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"shipment" => shipment}, socket) do

    %{id: id, name: name} = extract_data_from_destination(shipment["destination_group_id"])

    %{changeset: changeset} = socket.assigns

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
          {:noreply, push_patch(socket, to: Routes.live_path(socket, PurchaseShipmentLive, id: socket.assigns.purchase.id))}

        {:error, %Ecto.Changeset{} = changest} ->
          result = if name == "", do: id, else: "#{id}|#{name}"
          changeset = Ecto.Changeset.put_change(changeset, :destination_group_id, result)
          {:noreply, assign(socket, changeset: changeset)}
      end
    else
      result = if name == "", do: id, else: "#{id}|#{name}"
      changeset = Ecto.Changeset.put_change(changeset, :destination_group_id, result)
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("validate", %{"shipment" => shipment}, socket) do

    %{id: id, name: name} = extract_data_from_destination(shipment["destination_group_id"])
    %{changeset: changeset} = socket.assigns

    parent_destination =
      Enum.find(socket.assigns.destinations, %{id: "", name: ""}, fn item ->
        if(String.trim(id) == "") do
          item.id == id && !item.child
        else
          item.id == String.to_integer(id) && !item.child
        end
      end)

      shipment = Map.put(shipment, "destination_group_id", id)

    %{changeset: changeset} = socket.assigns

    changeset =
      changeset.data
      |> Shipments.change_shipment(shipment)
      |> Map.put(:action, :update)

    result = if name == "", do: id, else: "#{id}|#{name}"
    changeset = Ecto.Changeset.put_change(changeset, :destination_group_id, result)
    {:noreply, assign(socket, changeset: changeset)}
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
