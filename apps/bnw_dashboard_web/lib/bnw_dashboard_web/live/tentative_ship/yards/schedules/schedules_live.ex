defmodule BnwDashboardWeb.TentativeShip.Yards.Schedules.SchedulesLive do
  use BnwDashboardWeb, :live_view

  alias TentativeShip.Schedules

  defp fetch_schedules(socket) do
    %{yard_id: yard_id} = socket.assigns
    schedules =
      (Schedules.list_schedules(yard_id) ++ [Schedules.new_schedule()])
    assign(socket, schedules: schedules)
  end

  defp set_schedules(schedule, socket) do
    %{yard_id: yard_id} = socket.assigns
    cond do
      yard_id == schedule.yard_id -> fetch_schedules(socket)
      true -> socket
    end
  end

  @impl true
  def mount(_params, session, socket) do
    %{"parent_pid" => parent_pid, "yard_id" => yard_id} = session
    socket =
      socket
      |> assign(yard_id: yard_id, parent_pid: parent_pid)
      |> fetch_schedules()
    if connected?(socket), do: Schedules.subscribe()
    {:ok, socket}
  end

  # handle info
  @impl true
  def handle_info({[:schedule, _], schedule}, socket) do
    socket = set_schedules(schedule, socket)
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

  @impl true
  def handle_event("modal", params, socket) do
    %{yard_id: yard_id} = socket.assigns
    id = Map.get(params, "id", "new")
    %{parent_pid: parent_pid} = socket.assigns
    send(parent_pid, {:schedule, %{yard_id: yard_id, id: id}})
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    id
    |> Schedules.get_schedule!()
    |> Schedules.delete_schedule()
    {:noreply, socket}
  end
  # end handle event
end
