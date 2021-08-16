defmodule BnwDashboardWeb.TentativeShip.Yards.Destinations.DestinationLive do
  use BnwDashboardWeb, :live_view

  alias TentativeShip.Destinations

  @impl true
  def mount(_params, %{"destination" => destination, "yard_id" => yard_id, "id" => id}, socket) do
    changeset = Destinations.change_destination(destination)
    socket = assign(socket, changeset: changeset, yard_id: yard_id, view_id: id)
    if connected?(socket), do: Destinations.subscribe()
    {:ok, socket}
  end

  # handle info
  @impl true
  def handle_info({[:destination, :updated], destination}, socket) do
    %{changeset: changeset} = socket.assigns
    socket = cond do
      changeset.data.id == destination.id ->
        changeset = Destinations.change_destination(destination)
        assign(socket, changeset: changeset)
      true -> socket
    end
    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end
  # end handle info

  # handle event
  @impl true
  def handle_event("delete", _params, socket) do
    %{changeset: changeset} = socket.assigns
    Destinations.delete_destination(changeset.data)
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"destination" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = Destinations.change_destination(changeset.data, params)
    |> Map.put(:action, :update)
    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"destination" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    case Destinations.create_or_update_destination(changeset.data, params) do
      {:ok, _destination} ->
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, changeset: changeset)
        {:noreply, socket}
    end
  end
  # end handle event
end
