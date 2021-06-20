defmodule BnwDashboardWeb.Reimbursement.Users.AddUsers.UserLive do
  use BnwDashboardWeb, :live_view

  alias Reimbursement.{
    Users,
    UserRoles
  }

  @impl true
  def mount(_params, %{"roles" => roles, "user" => user}, socket) do

    roles = Enum.map(roles, &(%{name: &1.name, checked: Enum.find_value(user.users_roles, fn r -> r.role == &1.name end)}))

    socket = assign(socket, user: user, roles: roles)
    if connected?(socket) do
      Users.subscribe()
      UserRoles.subscribe()
    end
    {:ok, socket}
  end

  @impl true
  def handle_info({[:user, :updated], user_role}, socket) do
    %{user: user, roles: roles} = socket.assigns
    updated_user = Map.get(user_role, :user_id)
    role = Map.get(user_role, :role)

    socket = cond do
      user.id == updated_user ->
        roles = Enum.map(roles, &Map.put(&1, :checked, (if &1.name == role, do: !&1.checked, else: &1.checked)))
        assign(socket, roles: roles)
      true -> socket
    end
    {:noreply, socket}
  end

  @impl true
  def handle_event("change_role", %{"role" => role, "user" => user}, socket) do
    UserRoles.set_role(user, role)
    {:noreply, socket}
  end
end
