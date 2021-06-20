defmodule BnwDashboardWeb.Reimbursement.Help.HelpLiveUsers do
  use BnwDashboardWeb, :live_view

  @impl true
  def mount(_, _, socket) do
    socket = assign(socket,
      users_activate: false,
      users_assign_roles: false,
      users_assign_reviewer: false,
      users_roles: false)

    {:ok, socket}
  end

  @doc """
  This part of the page uses four handle_events
  All of which do the same thing but for different sections

  Show/Hide activate
  Show/Hide assign roles
  Show/Hide assign reviewer
  Show/Hide roles
  """
  @impl true
  def handle_event("users_activate", _, socket) do
    %{users_activate: users_activate} = socket.assigns
    socket = assign(socket, users_activate: !users_activate)
    {:noreply, socket}
  end

  @impl true
  def handle_event("users_assign_roles", _, socket) do
    %{users_assign_roles: users_assign_roles} = socket.assigns
    socket = assign(socket, users_assign_roles: !users_assign_roles)
    {:noreply, socket}
  end

  @impl true
  def handle_event("users_assign_reviewer", _, socket) do
    %{users_assign_reviewer: users_submission} = socket.assigns
    socket = assign(socket, users_assign_reviewer: !users_submission)
    {:noreply, socket}
  end

  @impl true
  def handle_event("users_roles", _, socket) do
    %{users_roles: users_roles} = socket.assigns
    socket = assign(socket, users_roles: !users_roles)
    {:noreply, socket}
  end
end
