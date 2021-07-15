defmodule BnwDashboardWeb.CattlePurchase.PurchaseTypeFilter.PurchaseTypeFilterLive do
  use BnwDashboardWeb, :live_view
  alias CattlePurchase.{
    Authorize,
    PurchaseTypeFilters,
    PurchaseTypes
  }
   alias BnwDashboardWeb.CattlePurchase.PurchaseTypeFilters.ChangePurchaseTypeFilterComponent

  defp authenticate(socket) do
    current_user = Map.get(socket.assigns, :current_user)
    cond do
      current_user && Authorize.authorize(current_user, "purchase_type_filters") ->
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
        page_title: "BNW Dashboard · Purchase Type Filter",
        app: "Cattle Purchase",
        purchase_type_filters: PurchaseTypeFilters.list_purchase_type_filters(),
        modal: nil,
        purchase_type_error: nil
      )
    if connected?(socket) do
      PurchaseTypeFilters.subscribe()
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

  @impl true
  def handle_event("new", _, socket) do
    changeset = PurchaseTypeFilters.new_purchase_type_filter()
    active_purchase_types =
      PurchaseTypes.get_active_purchase_types()
      |> Enum.map(fn item -> %{id: item.id, name: item.name, checked: false} end)
    if active_purchase_types == [] do
      {:noreply, put_flash(socket, :error, "There should be at least one active purchase type to create a purchase type filter")}
    else
      socket =
        assign(socket,
          changeset: changeset,
          modal: :change_purchase_type_filter,
          active_purchase_types: active_purchase_types
        )
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, modal: nil)
    {:noreply, socket}
  end
end
