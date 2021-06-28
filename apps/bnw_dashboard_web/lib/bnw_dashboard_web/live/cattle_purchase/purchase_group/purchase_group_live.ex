defmodule BnwDashboardWeb.CattlePurchase.PurchaseGroup.PurchaseGroupLive do
  use BnwDashboardWeb, :live_view

  alias CattlePurchase.{
    Authorize,
    PurchaseGroups
  }

  defp authenticate(socket) do
    current_user = Map.get(socket.assigns, :current_user)

    cond do
      current_user && Authorize.authorize(current_user, "page") ->
        true

      true ->
        false
    end
  end

  @impl true
  def mount(_, session, socket) do
    socket =
      assign_defaults(session, socket)
      |> assign(
        page_title: "Purchase Group",
        app: "Cattle Purchase",
        purchase_groups: PurchaseGroups.list_purchase_groups(),
        modal: nil
      )

    if connected?(socket) do
      PurchaseGroups.subscribe()
    end

    case authenticate(socket) do
      true -> {:ok, socket}
      false -> {:ok, redirect(socket, to: "/")}
    end
  end

  @impl true
  def handle_params(_, _, socket) do
    {:noreply, socket}
  end
end
