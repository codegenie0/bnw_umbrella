defmodule BnwDashboardWeb.CattlePurchase.PurchaseShipment.ChangePurchaseShipmentComponent do
  @moduledoc """
  ### Live view component for the add/update purchase shipment modal.
  """
  use BnwDashboardWeb, :live_component
  import Ecto.Changeset

  alias CattlePurchase.{
    Purchase,
    Shipments,
    Repo
  }

  alias BnwDashboardWeb.CattlePurchase.PurchaseShipment.PurchaseShipmentLive

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"shipment" => shipment} = _params, socket) do
    purchase_id = shipment["purchase_id"] |> String.to_integer()
    purchase = Repo.get(Purchase, purchase_id)
    socket = assign(socket, :shipment_form_data, shipment)
    %{changesets: changesets} = socket.assigns

    if(Enum.count(changesets) > 1) do
      cs_list =
        Enum.map(changesets, fn changeset ->
          %{changes: shipment} = changeset

          if is_integer(shipment.destination_group_id) do
            changeset = Map.put(changeset, :changes, shipment)
            Map.put(changeset, :action, :insert)
          else
            %{id: id, name: name} = extract_data_from_destination(shipment.destination_group_id)

            parent_destination =
              Enum.find(socket.assigns.destinations, %{id: "", name: ""}, fn item ->
                if(String.trim(id) == "") do
                  item.id == id && !item.child
                else
                  item.id == String.to_integer(id) && !item.child
                end
              end)

            shipment = Map.put(shipment, :destination_group_id, id |> String.to_integer())

            shipment =
              Map.put(
                shipment,
                :destination_group_name,
                "#{parent_destination.name}#{if name == "", do: "", else: " > #{name}"}"
              )

            changeset = Map.put(changeset, :changes, shipment)
            Map.put(changeset, :action, :insert)
          end
        end)

      Shipments.create_multiple_shipments(cs_list)

      {:noreply,
       push_patch(socket,
         to: Routes.live_path(socket, PurchaseShipmentLive, id: socket.assigns.purchase.id)
       )}
    else
      changeset = List.last(changesets)

      changeset_insert =
        if changeset.data.id == nil && already_have_shipments?(shipment["purchase_id"]) == false do
          if shipment["head_count"] != "" do
            if purchase.head_count != shipment["head_count"] |> String.to_integer() do
              add_error(changeset, :head_count, "Must be equal to the head_count of purchases")
            else
              changeset
            end
          else
            add_error(changeset, :head_count, "head count is blank")
          end
        end

      changeset = if is_nil(changeset_insert), do: changeset, else: changeset_insert

      if !changeset.valid? do
        {:noreply, assign(socket, changesets: [changeset])}
      else
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

        shipment_date_adjustment =
          if changeset.data.id != nil && changeset.data.estimated_ship_date &&
               shipment["estimated_ship_date"] !=
                 changeset.data.estimated_ship_date |> Date.to_string() &&
               changeset.data.projected_out_date &&
               shipment["projected_out_date"] ==
                 changeset.data.projected_out_date |> Date.to_string() do
            days =
              Date.diff(
                shipment["estimated_ship_date"] |> Date.from_iso8601!(),
                changeset.data.estimated_ship_date
              )

            Map.put(
              shipment,
              "projected_out_date",
              Date.add(changeset.data.projected_out_date, days)
            )
          end

        shipment = if shipment_date_adjustment, do: shipment_date_adjustment, else: shipment
        changeset = Shipments.validate(changeset.data, shipment)

        if changeset.valid? do
          case Shipments.create_or_update_shipment(changeset.data, shipment) do
            {:ok, _purchase} ->
              {:noreply,
               push_patch(socket,
                 to:
                   Routes.live_path(socket, PurchaseShipmentLive, id: socket.assigns.purchase.id)
               )}

            {:error, %Ecto.Changeset{} = _changest} ->
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
    end
  end

  def handle_event("validate", %{"shipment" => shipment}, socket) do
    %{id: id, name: name} = extract_data_from_destination(shipment["destination_group_id"])
    socket = assign(socket, :shipment_form_data, shipment)

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

    changeset =
      changeset.data
      |> Shipments.change_shipment(shipment)
      |> Map.put(:action, :update)

    changesets = List.replace_at(changesets, length(changesets) - 1, changeset)

    max_head_count =
      socket.assigns.max_head_count - (shipment["head_count"] |> String.to_integer())

    if changeset.valid? do
      changesets = changesets ++ [Shipments.new_shipment() |> Map.put(:action, :update)]

      {:noreply,
       assign(socket, changesets: changesets, add_feedback: false, max_head_count: max_head_count)}
    else
      {:noreply,
       assign(socket, changesets: changesets, add_feedback: true, max_head_count: max_head_count)}
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

  def already_have_shipments?(purchase_id) do
    purchase_shipments = Repo.get(Purchase, purchase_id) |> Repo.preload(:shipments)
    if purchase_shipments.shipments == [], do: false, else: true
  end
end
