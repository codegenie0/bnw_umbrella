defmodule BnwDashboardWeb.CattlePurchase.Purchase.PurchaseCommissionComponent do
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
    IO.inspect("oooooooooooooooooooooooooo")
    {:noreply, socket}
  end
end
