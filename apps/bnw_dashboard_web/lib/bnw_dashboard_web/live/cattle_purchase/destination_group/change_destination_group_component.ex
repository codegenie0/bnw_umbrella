defmodule BnwDashboardWeb.CattlePurchase.DestinationGroup.ChangeDestinationGroupComponent do
  @moduledoc """
  ### Live view component for the add/update destination groups modal.
  """
  use BnwDashboardWeb, :live_component
  alias CattlePurchase.DestinationGroup
  alias BnwDashboardWeb.CattlePurchase.DestinationGroup.DestinationGroupLive
  def mount(socket) do
    {:ok, socket}
  end


end
