defmodule BnwDashboardWeb.CattlePurchase.PurchaseFlag.PurchaseFlagLive do
  use BnwDashboardWeb, :live_view

  alias CattlePurchase.{
    Authorize,
    PurchaseFlags
  }

  alias BnwDashboardWeb.CattlePurchase.PurchaseFlags.ChangePurchaseFlagComponent

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
      |> fetch_purchase_flags()
      |> assign(
        page_title: "BNW Dashboard · Purchase Flag",
        app: "Cattle Purchase",
        modal: nil
      )

    if connected?(socket) do
      # subscribe here
      if connected?(socket) do
        PurchaseFlags.subscribe()
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
  def handle_info({[:purchase_flags, :created_or_updated], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
    {:noreply, fetch_purchase_flags(socket)}
  end

  @impl true
  def handle_info({[:purchase_flags, :deleted], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
    {:noreply, fetch_purchase_flags(socket)}
  end

  @impl true
  def handle_event("edit", params, socket) do
    {id, ""} = Integer.parse(params["id"])

    changeset =
      Enum.find(socket.assigns.purchase_flags, fn pg -> pg.id == id end)
      |> PurchaseFlags.change_purchase_flag()

    socket = assign(socket, changeset: changeset, modal: :change_purchase_flag)
    {:noreply, socket}
  end

  @impl true
  def handle_event("new", _, socket) do
    changeset = PurchaseFlags.new_purchase_flag()
    socket = assign(socket, changeset: changeset, modal: :change_purchase_flag)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", params, socket) do
    {id, ""} = Integer.parse(params["id"])

    Enum.find(socket.assigns.purchase_flags, fn pg -> pg.id == id end)
    |> PurchaseFlags.delete_purchase_flag()

    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, modal: nil)
    {:noreply, socket}
  end

  defp fetch_purchase_flags(socket) do
    assign(socket, purchase_flags: PurchaseFlags.list_purchase_flags())
  end
end
