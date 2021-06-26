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
      |> fetch_purchase_groups()
      |> assign(
        page_title: "BNW Dashboard · Purchase Group",
        app: "Cattle Purchase",
        modal: nil
      )

    if connected?(socket) do
      # subscribe here
      if connected?(socket) do
        PurchaseGroups.subscribe()
      end
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
  def handle_info({[:purchase_groups, :created_or_updated], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
    {:noreply, fetch_purchase_groups(socket)}
  end

  @impl true
  def handle_info({[:purchase_groups, :deleted], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
    {:noreply, fetch_purchase_groups(socket)}
  end

  @impl true
  def handle_event("edit", params, socket) do
    {id, ""} = Integer.parse(params["id"])

    changeset =
      Enum.find(socket.assigns.purchase_groups, fn pg -> pg.id == id end)
      |> PurchaseGroups.change_purchase_group()

    socket = assign(socket, changeset: changeset, modal: :change_purchase_group)
    {:noreply, socket}
  end

  @impl true
  def handle_event("new", _, socket) do
    changeset = PurchaseGroups.new_purchase_group()
    socket = assign(socket, changeset: changeset, modal: :change_purchase_group)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", params, socket) do
    {id, ""} = Integer.parse(params["id"])

    Enum.find(socket.assigns.purchase_groups, fn pg -> pg.id == id end)
    |> PurchaseGroups.delete_purchase_group()

    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, modal: nil)
    {:noreply, socket}
  end

  defp fetch_purchase_groups(socket) do
    assign(socket, purchase_groups: PurchaseGroups.list_purchase_groups())
  end
end
