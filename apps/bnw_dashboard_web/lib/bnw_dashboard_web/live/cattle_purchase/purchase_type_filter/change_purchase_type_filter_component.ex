defmodule BnwDashboardWeb.CattlePurchase.PurchaseTypeFilters.ChangePurchaseTypeFilterComponent do
  @moduledoc """
  ### Live view component for the add/update purchase type filters modal.
  """
  use BnwDashboardWeb, :live_component
  alias CattlePurchase.PurchaseTypeFilters
  alias BnwDashboardWeb.CattlePurchase.PurchaseTypeFilter.PurchaseTypeFilterLive
  def mount(socket) do
    {:ok, socket}
  end
end
