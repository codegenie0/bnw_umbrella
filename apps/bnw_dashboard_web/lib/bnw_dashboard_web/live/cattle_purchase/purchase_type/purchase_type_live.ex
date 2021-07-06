defmodule BnwDashboardWeb.CattlePurchase.PurchaseType.PurchaseTypeLive do
  use BnwDashboardWeb, :live_view

  alias CattlePurchase.{
    Authorize,
    PurchaseTypes
  }

  alias BnwDashboardWeb.CattlePurchase.PurchaseTypes.ChangePurchaseTypeComponent

  defp authenticate(socket) do
    current_user = Map.get(socket.assigns, :current_user)

    cond do
      current_user && Authorize.authorize(current_user, "purchase_types") ->
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
        page_title: "BNW Dashboard · Active Purchase Type",
        app: "Cattle Purchase",
        purchase_type: "active",
        purchase_types: PurchaseTypes.get_active_purchase_types(),
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

  @impl true
  def handle_event("new", _, socket) do
    changeset = PurchaseTypes.new_purchase_type()
    socket = assign(socket, changeset: changeset, modal: :change_purchase_type)
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit", params, socket) do
    {id, ""} = Integer.parse(params["id"])

    changeset =
      Enum.find(socket.assigns.purchase_types, fn pt -> pt.id == id end)
      |> PurchaseTypes.change_purchase_type()

    socket = assign(socket, changeset: changeset, modal: :change_purchase_type)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", params, socket) do
    {id, ""} = Integer.parse(params["id"])

    Enum.find(socket.assigns.purchase_types, fn pt -> pt.id == id end)
    |> PurchaseTypes.delete_purchase_type()

    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_event("set-active-purchase-type", _params, socket) do
    {:noreply,
     assign(socket,
       purchase_type: "active",
       page_title: "BNW Dashboard · Active Purchase Type",
       purchase_types: PurchaseTypes.get_active_purchase_types()
     )}
  end

  @impl true
  def handle_event("set-inactive-purchase-type", _params, socket) do
    {:noreply,
     assign(socket,
       purchase_type: "inactive",
       page_title: "BNW Dashboard · Inactive Purchase Type",
       purchase_types: PurchaseTypes.get_inactive_purchase_types()
     )}
  end

  @impl true
  def handle_info({[:purchase_types, :created_or_updated], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
    purchase_type = socket.assigns.purchase_type
    data = fetch_by_type(purchase_type)
    {:noreply, assign(socket, purchase_types: data)}
  end

  @impl true
  def handle_info({[:purchase_types, :deleted], _}, socket) do
    purchase_type = socket.assigns.purchase_type
    data = fetch_by_type(purchase_type)
    {:noreply, assign(socket, purchase_types: data)}
  end

  defp fetch_by_type(purchase_type) do
    if purchase_type == "active",
      do: PurchaseTypes.get_active_purchase_types(),
      else: PurchaseTypes.get_inactive_purchase_types()
  end
end
