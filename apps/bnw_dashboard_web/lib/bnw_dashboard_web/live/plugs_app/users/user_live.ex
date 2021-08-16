defmodule BnwDashboardWeb.PlugsApp.Users.UserLive do
  @moduledoc """
  ### Live view component for a specific user.
  This document renders one user onto the screen.
  If the current user is an IT admin they will have the option to add or remove admins or users from the application.
  Otherwise they will only be able to add or remove users from the application.
  """
  use BnwDashboardWeb, :live_view

  alias BnwDashboardWeb.PlugsApp.Users.ChangeUserRoleComponent
  alias PlugsApp.{
    Roles,
    Users
  }

  defp fetch_secondary_roles(socket) do
    current_user = Map.get(socket.assigns, :current_user)
    %{id: user_id} = current_user
    {admin, _} = Users.has_roll(user_id, "admin")
    if current_user.it_admin || admin do
      assign(socket,
        secondary_roles: Roles.list_secondary_roles(),
        admin: true)
    else
        assign(socket,
          secondary_roles: Users.list_secondary_roles(user_id),
          admin: false)
    end
  end

  @doc """
  This function is the entry point the live view. This is called when live_component(..., this, ...) is called
  """
  @impl true
  def mount(_params, %{"roles" => roles,
                       "user" => user,
                       "current_user" => current_user,
                       "it_admin" => it_admin}, socket) do
    roles = Enum.map(roles, &(%{name: &1, checked: Enum.find_value(user.users_roles, fn r -> r.role == &1 end)}))

    socket = assign(socket,
      user: user,
      roles: roles,
      current_user: current_user,
      it_admin: it_admin,
      modal: nil,
      modal_count: 0)
      |> fetch_secondary_roles()
    if connected?(socket), do: Users.subscribe()
    {:ok, socket}
  end

  @doc """
  Handle when this user is updated to display the new roles in the list.
  """
  @impl true
  def handle_info({[:user, :updated], user_role}, socket) do
    %{
      user: user,
      roles: roles,
    } = socket.assigns
    updated_user = Map.get(user_role, :user_id)
    role = Map.get(user_role, :role)

    socket = cond do
      user.id == updated_user ->
        roles = Enum.map(roles, &Map.put(&1, :checked, (if &1.name == role, do: !&1.checked, else: &1.checked)))
        assign(socket, roles: roles)
      true -> socket
    end
    my_roles = Users.get_users_rolls(user.id)
    socket = assign(socket, my_roles: my_roles)
      |> fetch_secondary_roles()
    {:noreply, socket}
  end

  @doc """
  Handle when this user is changed and commit to database
  """
  @impl true
  def handle_event("change_role", %{"level" => level, "role" => role, "user" => user_id}, socket) do
    Users.change_role(user_id, role, level)
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    {:noreply, assign(socket, modal: nil)}
  end

  @impl true
  def handle_event("edit_user", _, socket) do
    %{
      user: %{id: user_id},
      modal_count: modal_count
    } = socket.assigns
    my_roles = Users.get_users_rolls(user_id)
    {:noreply, assign(socket,
        modal_count: modal_count + 1,
        modal: :edit_user,
        my_roles: my_roles)}
  end
end
