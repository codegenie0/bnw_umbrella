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
end
