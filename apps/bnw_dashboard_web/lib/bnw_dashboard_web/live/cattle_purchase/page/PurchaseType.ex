defmodule BnwDashboardWeb.CattlePurchase.Page.PurchaseTypeLive do
  use BnwDashboardWeb, :live_view

  alias CattlePurchase.{
    Authorize
  }

  alias CattlePurchase.PurchaseTypes
  alias BnwDashboardWeb.CattlePurchase.Page.ChangePurchaseTypeComponent

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
        page_title: "BNW Dashboard · Active Purchase Type",
        app: "Cattle Purchase",
        purchase_type: "active",
        modal: nil
      )

    if connected?(socket) do
      # subscribe here
      if connected?(socket) do
        PurchaseTypes.subscribe()
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

  # @impl true
  # def handle_info({[:user, :updated], _customer}, socket) do
  #   case authenticate(socket) do
  #     true -> {:noreply, socket}
  #     false -> {:noreply, redirect(socket, to: "/")}
  #   end
  # end

  @impl true
  def handle_info({[:purchase_types, :created_or_updated], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
    {:noreply, fetch_purchase_types(socket)}
  end

  @impl true
  def handle_info({[:purchase_types, :deleted], _}, socket) do
    {:noreply, fetch_purchase_types(socket)}
  end

  # @impl true
  # def handle_info(_, socket) do
  #   {:noreply, socket}
  # end

  # end handle_info
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
  def handle_event("new", _, socket) do
    changeset = PurchaseTypes.new_purchase_type()
    IO.inspect(changeset)
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

  def handle_event("toggle-purchase-type", _params, socket) do
    case socket.assigns.purchase_type do
      "active" ->
        {:noreply,
         assign(socket,
           purchase_type: "inactive",
           page_title: "BNW Dashboard · Inactive Purchase Type"
         )}

      _ ->
        {:noreply,
         assign(socket,
           purchase_type: "active",
           page_title: "BNW Dashboard · Active Purchase Type"
         )}
    end
  end

  defp fetch_purchase_types(socket) do
    purchase_types = PurchaseTypes.list_purchase_types()

    assign(socket, purchase_types: purchase_types)
  end
end
