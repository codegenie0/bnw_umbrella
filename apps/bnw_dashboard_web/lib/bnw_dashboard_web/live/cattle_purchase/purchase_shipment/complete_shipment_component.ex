defmodule BnwDashboardWeb.CattlePurchase.Purchase.CompleteShipmentComponent do
  @moduledoc """
  ### Live view component for the add/update shipment complete.
  """
  use BnwDashboardWeb, :live_component
  alias CattlePurchase.Shipments

  def mount(socket) do
    {:ok, socket}
  end

  defp change_shipment_complete(socket, params, value) do
    {id, ""} = Integer.parse(params["id"])
    shipment = Enum.find(socket.assigns.shipments, fn pg -> pg.id == id end)

      shipment
      |> Shipments.create_or_update_shipment(%{complete: value})
  end
end
