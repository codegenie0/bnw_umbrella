defmodule BnwDashboardWeb.CattlePurchase.PurchaseGroup.PurchaseGroupLive do
  use BnwDashboardWeb, :live_view

  alias CattlePurchase.{
    Authorize,
    PurchaseGroups
  }
  alias BnwDashboardWeb.CattlePurchase.PurchaseGroups.ChangePurchaseGroupComponent

  defp authenticate(socket) do
    current_user = Map.get(socket.assigns, :current_user)

    cond do
      current_user && Authorize.authorize(current_user, "purchase_groups") ->
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

  @impl true
  def handle_event("new", _ , socket) do
    changeset = PurchaseGroups.new_purchase_group()
    socket = assign(socket, changeset: changeset, modal: :change_purchase_group)
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    changeset =
          Enum.find(socket.assigns.purchase_groups, fn pg -> pg.id == id end )
          |>PurchaseGroups.change_purchase_group()
    socket = assign(socket, changeset: changeset, modal: :change_purchase_group)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    Enum.find(socket.assigns.purchase_groups, fn pg -> pg.id == id end )
    |>PurchaseGroups.delete_purchase_group()
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:purchase_groups, :created_or_updated], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
    {:noreply, assign(socket, purchase_groups: PurchaseGroups.list_purchase_groups() )}
  end

  @impl true
  def handle_info({[:purchase_groups, :deleted], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
    {:noreply, assign(socket, purchase_groups: PurchaseGroups.list_purchase_groups() )}
  end
end
