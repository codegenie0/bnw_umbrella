defmodule BnwDashboardWeb.CattlePurchase.AnimalSexOrder.AnimalSexOrderLive do
  use BnwDashboardWeb, :live_view

  alias CattlePurchase.{
    Authorize,
    AnimalSexOrders
  }

  alias BnwDashboardWeb.CattlePurchase.AnimalSexOrder.ChangeAnimalSexOrderComponent

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
      |> fetch_animal_sex_orders()
      |> assign(
        page_title: "BNW Dashboard · Animal Sex Order",
        app: "Cattle Purchase",
        modal: nil,
        sex: nil
      )

    if connected?(socket) do
      # subscribe here
      if connected?(socket) do
        AnimalSexOrders.subscribe()
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
  def handle_info({[:animal_sex_orders, :created_or_updated], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
    {:noreply, fetch_animal_sex_orders(socket)}
  end

  @impl true
  def handle_info({[:animal_sex_orders, :deleted], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
    {:noreply, fetch_animal_sex_orders(socket)}
  end

  @impl true
  def handle_event("edit", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    sex = Enum.find(socket.assigns.animal_sex_orders, fn ao -> ao.id == id end)

    changeset =
      sex.animal_sex_order
      |> AnimalSexOrders.change_animal_sex_order()

    socket = assign(socket, changeset: changeset, modal: :change_animal_sex_order, sex: sex)
    {:noreply, socket}
  end

  @impl true
  def handle_event("new", _, socket) do
    changeset = AnimalSexOrders.new_animal_sex_order()
    socket = assign(socket, changeset: changeset, modal: :change_animal_sex_order)
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, modal: nil)
    {:noreply, socket}
  end

  defp fetch_animal_sex_orders(socket) do
    assign(socket, animal_sex_orders: AnimalSexOrders.list_animal_sex_orders())
  end
end
