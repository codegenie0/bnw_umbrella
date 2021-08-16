defmodule BnwDashboardWeb.TentativeShip.Yards.Destinations.DestinationsLive do
  use BnwDashboardWeb, :live_view

  alias TentativeShip.Destinations
  alias BnwDashboardWeb.TentativeShip.Yards.Destinations.DestinationLive

  defp fetch_destinations(socket) do
    %{yard_id: yard_id} = socket.assigns
    destinations =
      (Destinations.list_destinations(yard_id) ++ [Destinations.new_destination()])
    assign(socket, destinations: destinations)
  end

  defp set_destinations(destination, socket) do
    %{yard_id: yard_id} = socket.assigns
    cond do
      yard_id == destination.yard_id -> fetch_destinations(socket)
      true -> socket
    end
  end

  @impl true
  def mount(_params, session, socket) do
    %{"parent_pid" => parent_pid, "yard_id" => yard_id} = session
    socket =
      socket
      |> assign(yard_id: yard_id, parent_pid: parent_pid)
      |> fetch_destinations()
    if connected?(socket), do: Destinations.subscribe()
    {:ok, socket}
  end

  # handle info
  @impl true
  def handle_info({[:destination, :created], destination}, socket) do
    socket = set_destinations(destination, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:destination, :deleted], destination}, socket) do
    socket = set_destinations(destination, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end
  # end handle info

  # handle event
  @impl true
  def handle_event("cancel", _, socket) do
    %{parent_pid: parent_pid} = socket.assigns
    send(parent_pid, {:save, nil})
    {:noreply, socket}
  end
  # end handle event
end
