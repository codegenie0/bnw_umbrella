defmodule BnwDashboardWeb.TentativeShip.Home.HomeLive do
  use BnwDashboardWeb, :live_view

  alias TentativeShip.{
    Schedules,
    Yards
  }
  alias BnwDashboardWeb.TentativeShip.Home.{
    ShipmentsComponent,
    SummaryComponent,
    WeeklySummaryComponent
  }

  @impl true
  def mount(_params, session, socket) do
    socket =
      assign_defaults(session, socket)
      |> assign(:page_title, "BNW Dashboard · Tentative Shipments")
      |> assign(:app, "Tentative Shipments")
    {:ok, socket}
  end

  # handle params
  @impl true
  def handle_params(params, _uri, socket) do
    socket =
      socket
      |> assign(:page_title, "BNW Dashboard · Tentative Shipments")
      |> assign(:app, "Tentative Shipments")
      |> assign_yards()
      |> set_active_yard()
      |> assign_yard_views()
      |> set_active_yard_view()
      |> assign_schedules()
      |> set_active_schedule()
      |> assign_params(params)
    {:noreply, socket}
  end
  # end handle params

  defp assign_params(socket, %{"yard" => yard_id} = params) do
    params = Map.delete(params, "yard")
    yards = socket.assigns.yards
    yard_id = Integer.parse(yard_id)
    cond do
      yard_id == :error -> set_active_yard(socket)
      ({y_id, _} = yard_id) && Enum.any?(yards, &(&1.id == y_id)) -> set_active_yard(socket, y_id)
      true -> set_active_yard(socket)
    end
    |> assign_schedules()
    |> assign_params(params)
  end

  defp assign_params(socket, %{"yard_view" => name} = params) do
    params = Map.delete(params, "yard_view")
    yard_views = socket.assigns.yard_views
    cond do
      Enum.any?(yard_views, &(&1.name == name)) ->
        set_active_yard_view(socket, name)
      true -> set_active_yard_view(socket)
    end
    |> set_active_schedule()
    |> assign_params(params)
  end

  defp assign_params(socket, %{"schedule" => schedule_id} = params) do
    params = Map.delete(params, "schedule")
    schedules = socket.assigns.schedules
    schedule_id = Integer.parse(schedule_id)
    cond do
      schedule_id == :error -> set_active_schedule(socket)
      ({s_id, _} = schedule_id) && Enum.any?(schedules, &(&1.id == s_id)) -> set_active_schedule(socket, s_id)
      true -> set_active_schedule(socket)
    end
    |> assign_params(params)
  end

  defp assign_params(socket, _params) do
    socket
  end

  # handle info
  # end handle info

  # handle event
  @impl true
  def handle_event("change_yard", %{"id" => id}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{yard: id}), replace: true)}
  end

  @impl true
  def handle_event("change_yard_view", %{"name" => name}, socket) do
    yard =
      socket.assigns.yards
      |> Enum.find(&(&1.active))
      |> Map.get(:id)
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{yard_view: name, yard: yard}), replace: true)}
  end

  @impl true
  def handle_event("change_schedule", %{"id" => id}, socket) do
    %{yards: yards, yard_views: yard_views} = socket.assigns
    yard =
      yards
      |> Enum.find(&(&1.active))
      |> Map.get(:id)

    yard_view =
      yard_views
      |> Enum.find(&(&1.active))
      |> Map.get(:name)

    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{yard_view: yard_view, yard: yard, schedule: id}), replace: true)}
  end

  @impl true
  def handle_event("load_more", _params, socket) do
    %{
      current_user: current_user
    } = socket.assigns

    send_update(
      ShipmentsComponent,
      id: "shipments_#{current_user.id}",
      load_more: true
    )
    {:noreply, socket}
  end
  # end handle event

  defp assign_yards(socket) do
    assign(socket, :yards, get_yards())
  end

  defp assign_yard_views(socket) do
    assign(socket, :yard_views, get_yard_views())
  end

  defp assign_schedules(socket) do
    %{yards: yards} = socket.assigns
    schedules =
      yards
      |> Enum.find(&(&1.active))
      |> Map.get(:id)
      |> get_schedules()
    assign(socket, :schedules, schedules)
  end

  defp set_active_yard(socket) do
    id =
      socket.assigns.yards
      |> Enum.at(0, %{id: 0})
      |> Map.get(:id)

    set_active_yard(socket, id)
  end

  defp set_active_yard(socket, id) do
    yards =
      socket.assigns.yards
      |> Enum.map(&(
        cond do
          &1.id == id -> Map.put(&1, :active, true)
          true -> Map.put(&1, :active, false)
        end
      ))
    assign(socket, :yards, yards)
  end

  defp set_active_yard_view(socket) do
    name =
      socket.assigns.yard_views
      |> Enum.at(0, %{name: nil})
      |> Map.get(:name)

    set_active_yard_view(socket, name)
  end

  defp set_active_yard_view(socket, name) do
    yard_views =
      socket.assigns.yard_views
      |> Enum.map(&(
        cond do
          &1.name == name -> Map.put(&1, :active, true)
          true -> Map.put(&1, :active, false)
        end
      ))
    assign(socket, :yard_views, yard_views)
  end

  defp set_active_schedule(socket) do
    id =
      socket.assigns.schedules
      |> Enum.at(0, %{id: nil})
      |> Map.get(:id)

    set_active_schedule(socket, id)
  end

  defp set_active_schedule(socket, id) do
    schedules =
      socket.assigns.schedules
      |> Enum.map(&(
        cond do
          &1.id == id -> Map.put(&1, :active, true)
          true -> Map.put(&1, :active, false)
        end
      ))
    assign(socket, :schedules, schedules)
  end

  defp get_yards() do
    Yards.list_yards()
    |> Enum.map(&(%{id: &1.id, name: &1.name, active: false}))
  end

  defp get_yard_views() do
    [
      %{name: "Summary", active: false},
      %{name: "Shipments", active: false},
      %{name: "Weekly Summary", active: false}
    ]
  end

  defp get_schedules(yard_id) do
    yard_id
    |> Schedules.list_active_schedules()
    |> Enum.map(&(%{id: &1.id, name: &1.name, active: false}))
  end
end
