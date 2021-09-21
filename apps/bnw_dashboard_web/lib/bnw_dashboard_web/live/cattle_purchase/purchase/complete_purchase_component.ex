defmodule BnwDashboardWeb.CattlePurchase.Purchase.CompletePurchaseComponent do
  @moduledoc """
  ### Live view component for the add/update purchase complete.
  """
  use BnwDashboardWeb, :live_component
  alias CattlePurchase.Purchases

  def mount(socket) do
    {:ok, socket}
  end

  defp change_purchase_complete(socket, params, value) do
    {id, ""} = Integer.parse(params["id"])
    purchase = Enum.find(socket.assigns.purchases, fn pg -> pg.id == id end)

      purchase
      |> Purchases.create_or_update_purchase(%{complete: value})
  end
end
