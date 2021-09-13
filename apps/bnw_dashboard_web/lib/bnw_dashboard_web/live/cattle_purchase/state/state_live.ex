defmodule BnwDashboardWeb.CattlePurchase.State.StateLive do
  use BnwDashboardWeb, :live_view

  alias CattlePurchase.{
    Authorize,
    States
  }

  alias BnwDashboardWeb.CattlePurchase.States.ChangeStateComponent

  defp authenticate(socket) do
    current_user = Map.get(socket.assigns, :current_user)

    cond do
      current_user && Authorize.authorize(current_user, "states") ->
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
        page_title: "Active State",
        app: "Cattle Purchase",
        state: "active",
        states: States.get_active_states(),
        modal: nil
      )

    if connected?(socket) do
      States.subscribe()
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
    changeset = States.new_state()
    socket = assign(socket, changeset: changeset, modal: :change_state)
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit", params, socket) do
    {id, ""} = Integer.parse(params["id"])

    changeset =
      Enum.find(socket.assigns.states, fn pt -> pt.id == id end)
      |> States.change_state()

    socket = assign(socket, changeset: changeset, modal: :change_state)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", params, socket) do
    {id, ""} = Integer.parse(params["id"])

    Enum.find(socket.assigns.states, fn pt -> pt.id == id end)
    |> States.delete_state()

    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_event("set-active-state", _params, socket) do
    {:noreply,
     assign(socket,
       state: "active",
       page_title: "Active State",
       states: States.get_active_states()
     )}
  end

  @impl true
  def handle_event("set-inactive-state", _params, socket) do
    {:noreply,
     assign(socket,
       state: "inactive",
       page_title: "Inactive State",
       states: States.get_inactive_states()
     )}
  end

  @impl true
  def handle_info({[:states, :created_or_updated], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
    state = socket.assigns.state
    data = fetch_by_type(state)
    {:noreply, assign(socket, states: data)}
  end

  @impl true
  def handle_info({[:states, :deleted], _}, socket) do
    state = socket.assigns.state
    data = fetch_by_type(state)
    {:noreply, assign(socket, states: data)}
  end

  defp fetch_by_type(state) do
    if state == "active",
      do: States.get_active_states(),
      else: States.get_inactive_states()
  end
end
