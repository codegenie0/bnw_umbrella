defmodule BnwDashboardWeb.BorrowingBase.Companies.Users.UserLive do
  use BnwDashboardWeb, :live_view

  alias BorrowingBase.Users

  @impl true
  def mount(_params, %{"roles" => roles, "user" => user}, socket) do
    roles = Enum.map(roles, &(%{name: &1.name, id: &1.id, checked: Enum.find_value(user.users_roles, fn r -> r.role_id == &1.id end)}))
    socket = assign(socket, user: user, roles: roles)
    if connected?(socket), do: Users.subscribe()
    {:ok, socket}
  end

  @impl true
  def handle_info({[:user, :updated], updated_user}, socket) do
    %{user: user, roles: roles} = socket.assigns

    socket = cond do
      user.id == updated_user.id ->
        roles = Enum.map(roles, &(%{name: &1.name, id: &1.id, checked: Enum.find_value(updated_user.users_roles, fn r -> r.role_id == &1.id end)}))
        assign(socket, roles: roles)
      true -> socket
    end
    {:noreply, socket}
  end

  @impl true
  def handle_event("change_role", %{"role" => role, "user" => user}, socket) do
    Users.change_role(user, role)
    {:noreply, socket}
  end
end
