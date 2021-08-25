defmodule BnwDashboardWeb.CattlePurchase.Destination.DestinationLive do
  use BnwDashboardWeb, :live_view
  alias CattlePurchase.{
    Authorize,
    Destinations
  }
  alias BnwDashboardWeb.CattlePurchase.Destination.ChangeDestinationComponent
  alias BnwDashboardWeb.CattlePurchase.DestinationGroup.DestinationGroupLive

  defp authenticate(socket) do
    current_user = Map.get(socket.assigns, :current_user)
    cond do
      current_user && Authorize.authorize(current_user, "destinations") ->
        true
      true ->
        false
    end
  end

  @impl true
  def mount(params, session, socket) do
    {id, ""} = Integer.parse(params["id"])
    socket =
      assign_defaults(session, socket)
      |> assign(
        page_title: "Active Destination ",
        app: "Cattle Purchase",
        destination_type: "active",
        modal: nil,
        parent_id: id,
        destinations: Destinations.list_active_destinations(id)
      )
    if connected?(socket) do
      Destinations.subscribe()
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
    changeset = Destinations.new_destination()
    socket = assign(socket, changeset: changeset, modal: :change_destination)
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    changeset =
      Enum.find(socket.assigns.destinations, fn pt -> pt.id == id end)
      |> Destinations.change_destination()
    socket = assign(socket, changeset: changeset, modal: :change_destination)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    Enum.find(socket.assigns.destinations, fn pt -> pt.id == id end)
    |> Destinations.delete_destination()
    {:noreply, socket}
  end

  @impl true
  def handle_event("set-active-destination-type", _params, socket) do
    {:noreply,
     assign(socket,
       destination_type: "active",
       page_title: "Active Destination",
       destinations: Destinations.list_active_destinations(socket.assigns.parent_id)
     )}
  end

  @impl true
  def handle_event("set-inactive-destination-type", _params, socket) do
    {:noreply,
     assign(socket,
       destination_type: "inactive",
       page_title: "Inactive Destination",
       destinations: Destinations.list_inactive_destinations(socket.assigns.parent_id)
     )}
  end

  @impl true
  def handle_info({[:destinations, :created_or_updated], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
    destination_type = socket.assigns.destination_type
    data = fetch_by_type(destination_type, socket.assigns.parent_id)
    {:noreply, assign(socket, destinations: data)}
  end

  @impl true
  def handle_info({[:destinations, :deleted], _}, socket) do
    destination_type = socket.assigns.destination_type
    data = fetch_by_type(destination_type, socket.assigns.parent_id)
    {:noreply, assign(socket, destinations: data)}
  end

  defp fetch_by_type(destination_type, parent_id) do
    if destination_type == "active",
      do: Destinations.list_active_destinations(parent_id),
      else: Destinations.list_inactive_destinations(parent_id)
  end
end
