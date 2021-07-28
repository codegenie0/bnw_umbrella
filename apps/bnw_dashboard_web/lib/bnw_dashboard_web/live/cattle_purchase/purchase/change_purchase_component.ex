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

  def handle_event("validate", params, socket) do
    extract_destination_group(socket.assigns.destinations, params["purchase"]["destination_group_id"])
    {:noreply, socket}
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

  def extract_destination_group(destinations, value) do
    name = Enum.at(String.split(value, "|"), 1)
    name = Enum.find(destinations, fn x -> x.name == name end)
    IO.inspect(name)
  end
end
