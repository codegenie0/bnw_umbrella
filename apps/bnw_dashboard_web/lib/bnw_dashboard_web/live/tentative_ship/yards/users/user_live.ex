defmodule BnwDashboardWeb.TentativeShip.Yards.Users.UserLive do
  use BnwDashboardWeb, :live_view

  alias TentativeShip.{
    Roles,
    Users
  }

  defp set_roles(socket) do
    %{user: user, roles: roles} = socket.assigns
    roles =
      Enum.map(roles, fn r ->
        active = Enum.any?(user.roles, &(&1.id == r.id))
        Map.put(r, :active, active)
      end)
    assign(socket, roles: roles)
  end

  @impl true
  def mount(_params, %{"user" => user, "id" => id, "roles" => roles, "yard_id" => yard_id}, socket) do
    socket =
      socket
      |> assign(user: user, view_id: id, roles: roles, yard_id: yard_id)
      |> set_roles()
    if connected?(socket) do
      Users.subscribe()
      Roles.subscribe()
    end
    {:ok, socket}
  end

  # handle info
  @impl true
  def handle_info({[:user, :role_updated], user}, socket) do
    %{user: curr_user} = socket.assigns
    socket = cond do
      user.id == curr_user.id ->
        socket
        |> assign(user: user)
        |> set_roles()
      true -> socket
    end
    {:noreply, socket}
  end

  def handle_info({[:role, :created], role}, socket) do
    %{yard_id: yard_id, roles: roles} = socket.assigns
    socket =
      cond do
        role.yard_id == yard_id ->
          role = Map.put(role, :active, false)
          assign(socket, roles: (roles ++ [role]))
        true -> socket
      end
    {:noreply, socket}
  end

  def handle_info({[:role, :deleted], role}, socket) do
    %{yard_id: yard_id, roles: roles} = socket.assigns
    socket =
      cond do
        role.yard_id == yard_id ->
          roles = Enum.reject(roles, &(&1.id == role.id))
          assign(socket, roles: roles)
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
  def handle_event("change_role", %{"role-id" => role_id}, socket) do
    %{user: user} = socket.assigns
    role_id = String.to_integer(role_id)
    Users.change_role(user.id, role_id)
    {:noreply, socket}
  end
  # end handle event
end
