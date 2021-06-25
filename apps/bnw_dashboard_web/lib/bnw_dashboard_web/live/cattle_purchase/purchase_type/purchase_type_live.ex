defmodule BnwDashboardWeb.CattlePurchase.Page.PurchaseTypeLive do
  use BnwDashboardWeb, :live_view

  alias CattlePurchase.{
    Authorize,
    PurchaseTypes
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
      |> fetch_purchase_types()
      |> assign(
        page_title: "Active Purchase Type",
        app: "Cattle Purchase",
        purchase_type: "active",
        modal: nil
      )

    if connected?(socket) do
      PurchaseTypes.subscribe()
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

  defp fetch_purchase_types(socket) do
    purchase_types = PurchaseTypes.list_purchase_types()
    assign(socket, purchase_types: purchase_types)
  end
end
