defmodule BnwDashboardWeb.TentativeShip.Yards.YardNumbers.YardNumberLive do
  use BnwDashboardWeb, :live_view

  alias TentativeShip.YardNumbers

  @impl true
  def mount(_params, %{"yard_number" => yard_number, "yard_id" => yard_id, "id" => id}, socket) do
    changeset = YardNumbers.change_yard_number(yard_number)
    socket = assign(socket, changeset: changeset, yard_id: yard_id, view_id: id)
    if connected?(socket), do: YardNumbers.subscribe()
    {:ok, socket}
  end

  # handle info
  @impl true
  def handle_info({[:yard_number, :updated], yard_number}, socket) do
    %{changeset: changeset} = socket.assigns
    socket = cond do
      changeset.data.id == yard_number.id ->
        changeset = YardNumbers.change_yard_number(yard_number)
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
    YardNumbers.delete_yard_number(changeset.data)
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"yard_number" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = YardNumbers.change_yard_number(changeset.data, params)
    |> Map.put(:action, :update)
    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"yard_number" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    case YardNumbers.create_or_update_yard_number(changeset.data, params) do
      {:ok, _yard_number} ->
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, changeset: changeset)
        {:noreply, socket}
    end
  end
  # end handle event
end
