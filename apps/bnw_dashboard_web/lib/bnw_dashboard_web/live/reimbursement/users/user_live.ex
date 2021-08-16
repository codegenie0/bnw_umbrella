defmodule BnwDashboardWeb.Reimbursement.Users.UserLive do
  @moduledoc """
  ### Live view component for a specific user.
  This document renders one user onto the screen.
  If the current user is an IT admin they will have the option to add or remove admins or users from the application.
  Otherwise they will only be able to add or remove users from the application.
  """
  use BnwDashboardWeb, :live_view

  alias BnwDashboardWeb.Reimbursement.Users.UsersLive

  alias Reimbursement.{
    Users,
    UserRoles
  }

  defp assign_reviewers(socket) do
    %{user: user} = socket.assigns
    my_reviewer = UserRoles.get_reviewer(user.id)
    reviewers =
      UserRoles.list_reviewers()
      |> Enum.map(&([key: &1.name, value: &1.id]))

    reviewers = cond do
      my_reviewer.id == -1 ->
        [[key: "None", value: -1]] ++ reviewers
      true ->
        reviewers
    end

    assign(socket, my_reviewer: my_reviewer.id, reviewers: reviewers)
  end

  defp check_role(socket, user) do
    assign(socket, is_user: UserRoles.get_a_role(user.id, "user"))
  end

  @doc """
  This function is the entry point the live view. This is called when live_component(..., this, ...) is called
  """
  @impl true
  def mount(_params, %{"roles" => roles,
                       "user" => user,
                       "it_admin" => it_admin,
                       "reviewers" => reviewers}, socket) do

    roles = Enum.map(roles, &(%{name: &1.name, desc: &1.desc, checked: Enum.find_value(user.users_roles, fn r -> r.role == &1.name end)}))

    socket = assign(socket,
      user: user,
      roles: roles,
      it_admin: it_admin,
      reviewers: reviewers)
      |> assign_reviewers()
      |> check_role(user)


    if connected?(socket) do
      Users.subscribe()
      UserRoles.subscribe()
    end
    {:ok, socket}
  end

  @doc """
  Handle when this user is updated to display the new roles in the list.
  """
  @impl true
  def handle_info({[:user, :updated], user_role}, socket) do
    %{user: user, roles: roles} = socket.assigns
    updated_user = Map.get(user_role, :user_id)
    role = Map.get(user_role, :role)

    socket = UsersLive.fetch_reviewers(socket)
      |> assign_reviewers()
      |> check_role(user)
    socket = cond do
      user.id == updated_user ->
        roles = Enum.map(roles, &Map.put(&1, :checked, (if &1.name == role, do: !&1.checked, else: &1.checked)))
        assign(socket, roles: roles)
      true -> socket
    end
    {:noreply, socket}
  end

  @doc """
  Handle when this user is changed and commit to database
  """
  @impl true
  def handle_event("change_role", %{"role" => role, "user" => user}, socket) do
    UserRoles.set_role(user, role)
    {:noreply, socket}
  end

  @impl true
  def handle_event("change_reviewer", %{"change_reviewer" => change_reviewer}, socket) do
    %{"change_reviewer" => reviewer, "user_id" => user} = change_reviewer
    if not is_nil(reviewer) && not is_nil(user) do
      UserRoles.set_reviewer(user, reviewer)
    end
    {:noreply, socket}
  end
end
