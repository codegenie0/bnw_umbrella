defmodule BnwDashboardWeb.CattlePurchase.Purchase.ChangePurchaseComponent do
  @moduledoc """
  ### Live view component for the add/update purchase modal.
  """
  use BnwDashboardWeb, :live_component
  alias CattlePurchase.Purchases
  alias BnwDashboardWeb.CattlePurchase.Purchase.PurchaseLive

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", params, socket) do
    %{"purchase" => purchase} = params
    %{"button" => button} = purchase
    socket = assign(socket, submit_type: button)

    purchase =
      Map.put(purchase, "purchase_flag_ids", get_purchase_flags(socket.assigns.purchase_flags))

    %{id: id, name: name} = extract_data_from_destination(purchase["destination_group_id"])

    %{changeset: changeset} = socket.assigns

    parent_destination =
      Enum.find(socket.assigns.destinations, %{id: "", name: ""}, fn item ->
        if(String.trim(id) == "") do
          item.id == id && !item.child
        else
          item.id == String.to_integer(id) && !item.child
        end
      end)

    purchase = Map.put(purchase, "destination_group_id", id)

    # purchase_adjustment =
    #   if changeset.data.id != nil && changeset.data.estimated_ship_date &&
    #        purchase["estimated_ship_date"] !=
    #          changeset.data.estimated_ship_date |> Date.to_string() &&
    #        changeset.data.projected_out_date &&
    #        purchase["projected_out_date"] == changeset.data.projected_out_date |> Date.to_string() do
    #     days =
    #       Date.diff(
    #         purchase["estimated_ship_date"] |> Date.from_iso8601!(),
    #         changeset.data.estimated_ship_date
    #       )

    #     Map.put(purchase, "projected_out_date", Date.add(changeset.data.projected_out_date, days))
    #   end

    # purchase = if purchase_adjustment, do: purchase_adjustment, else: purchase

    purchase =
      Map.put(
        purchase,
        "destination_group_name",
        "#{parent_destination.name}#{if name == "", do: "", else: " > #{name}"}"
      )

    changeset = Purchases.validate(changeset.data, purchase)

    if changeset.valid? do
      case Purchases.create_or_update_purchase(changeset.data, purchase) do
        {:ok, purchase} ->
          send(
            socket.assigns.parent_pid,
            {:purchase_created, button: button, purchase_id: purchase.id}
          )

          {:noreply,
           push_patch(socket,
             to: Routes.live_path(socket, PurchaseLive)
           )}

        {:error, %Ecto.Changeset{} = _changest} ->
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

  def handle_event("validate", %{"purchase" => purchase}, socket) do
    purchase =
      Map.put(purchase, "purchase_flag_ids", get_purchase_flags(socket.assigns.purchase_flags))

    %{id: id, name: name} = extract_data_from_destination(purchase["destination_group_id"])

    purchase = Map.put(purchase, "destination_group_id", id)

    %{changeset: changeset} = socket.assigns

    changeset =
      changeset.data
      |> Purchases.change_purchase(purchase)
      |> Map.put(:action, :update)

    result = if name == "", do: id, else: "#{id}|#{name}"
    changeset = Ecto.Changeset.put_change(changeset, :destination_group_id, result)
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event(
        "handle_toggle_purchase_flag",
        %{"id" => _} = params,
        socket
      ) do
    {id, ""} = Integer.parse(params["id"])

    purchase_flags =
      socket.assigns.purchase_flags
      |> Enum.map(fn item ->
        if(item.id == id) do
          Map.put(item, :checked, !item.checked)
        else
          item
        end
      end)

    {:noreply, assign(socket, purchase_flags: purchase_flags)}
  end

  def handle_event("init_commission", _, socket) do
    commissions = [%{"commission_per_hundred" => 0, "commission_payee_id" => ""}]
    {:noreply, assign(socket, is_commission_init: true, commissions: commissions)}
  end

  def handle_event("add_commission", _, socket) do
    commissions =
      socket.assigns.commissions ++
        [%{"commission_per_hundred" => 0, "commission_payee_id" => ""}]

    {:noreply, assign(socket, commissions: commissions)}
  end

  def get_purchase_flags(purchase_flags) do
    Enum.reduce(purchase_flags, [], fn purchase_flag, list ->
      if(purchase_flag.checked) do
        list ++ [purchase_flag.id]
      else
        list
      end
    end)
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
