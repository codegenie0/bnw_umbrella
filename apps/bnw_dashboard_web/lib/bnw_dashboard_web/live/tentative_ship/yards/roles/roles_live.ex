defmodule BnwDashboardWeb.TentativeShip.Yards.Roles.RolesLive do
  use BnwDashboardWeb, :live_view

  alias TentativeShip.Roles
  alias BnwDashboardWeb.TentativeShip.Yards.Roles.RoleLive

  defp fetch_roles(socket) do
    %{yard_id: yard_id} = socket.assigns
    roles = (Roles.list_roles(yard_id) ++ [Roles.new_role() |> Map.put(:permissions, [])])
    assign(socket, roles: roles)
  end

  @impl true
  def mount(_params, session, socket) do
    %{"parent_pid" => parent_pid, "yard_id" => yard_id} = session
    socket =
      socket
      |> assign(yard_id: yard_id, parent_pid: parent_pid)
      |> fetch_roles()
    if connected?(socket), do: Roles.subscribe()
    {:ok, socket}
  end

  # handle info
  @impl true
  def handle_info({[:role, :created], role}, socket) do
    socket = set_roles(role, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:role, :deleted], role}, socket) do
    socket = set_roles(role, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end
  # end hadle info

  defp set_roles(role, socket) do
    %{yard_id: yard_id} = socket.assigns
    cond do
      yard_id == role.yard_id -> fetch_roles(socket)
      true -> socket
    end
  end

  # handle event
  @impl true
  def handle_event("cancel", _, socket) do
    %{parent_pid: parent_pid} = socket.assigns
    send(parent_pid, {:save, nil})
    {:noreply, socket}
  end
  # end handle event
end
