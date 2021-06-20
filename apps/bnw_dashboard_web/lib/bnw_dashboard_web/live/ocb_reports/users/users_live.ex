defmodule BnwDashboardWeb.OcbReportPlugs.Users.UsersLive do
  @moduledoc """
  ### Live view for the OCB report users page.
  This document renders the administrative OCB page. Allowing administrators to add and remove users while allowing IT to add and remove Admins and users
  """
  use BnwDashboardWeb, :live_view

  alias BnwDashboardWeb.OcbReportPlugs.Users.UserLive
  alias OcbReportPlugs.{
    Authorize,
    Roles,
    Users
  }

  # Private function that authenticates a user by testing if the current user has access to view the current page.
  defp authenticate(socket) do
    current_user = Map.get(socket.assigns, :current_user)
    cond do
      current_user && Authorize.authorize(current_user, "users") ->
        true
      true ->
        false
    end
  end

  # Private function that gets all users
  defp fetch_users(socket) do
    %{page: page, per_page: per_page, search: search} = socket.assigns
    roles =
      Roles.list_roles()
      |> Enum.map(&(&1.name))
    users = Users.list_users(page, per_page, search)
    assign(socket, users: users, roles: roles)
  end

  @doc """
  This function is the entry point the live view. This is called when live_component(..., this, ...) is called
  """
  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(session, socket)
    |> assign(socket,
              page_title: "BNW Dashboard · OCB Plugs Users",
              app: "OCB Report Plugs",
              search: "")

    if connected?(socket), do: Users.subscribe()
    case authenticate(socket) do
      true -> {:ok, socket}
      false -> {:ok, redirect(socket, to: "/")}
    end
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    per_page = 20
    search = ""
    socket =
      socket
      |> assign(page_title: "BNW Dashboard · OCB Report Plugs Users",
                app: "OCB Report Plugs",
                update_action: "replace",
                page: 1,
                total_pages: Users.total_pages(per_page, search),
                per_page: per_page,
                search: search)
      |> fetch_users()

    {:noreply, socket}
  end

  # handle info
  @doc """
  Handle when a user is updated so that if their permissions are updated they will be evicted from the application and the side bar will update with accordingly to their new status.
  """
  @impl true
  def handle_info({[:user, :updated], _customer}, socket) do
    case authenticate(socket) do
      true -> {:noreply, socket}
      false -> {:noreply, redirect(socket, to: "/")}
    end
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end
  # handle info end

  # handle event
  @doc """
  Handle when a user is updated to commit the new role to database and broadcast their new role information.

  Handle when an admin scrolls the user page far enough to load in more users.

  Handle when an admin searches for a certain user.
  """
  @impl true
  def handle_event("change_role", %{"role" => role, "user" => user}, socket) do
    Users.change_role(user, role)
    {:noreply, socket}
  end

  @impl true
  def handle_event("load_more", _, socket) do
    %{page: page, per_page: per_page, search: search, total_pages: total_pages} = socket.assigns
    page = page + 1
    cond do
      page > total_pages ->
        {:noreply, socket}
      true ->
        users = Users.list_users(page, per_page, search)
        socket = assign(socket, update_action: "append", page: page, users: users)
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("search", %{"search" => %{"search" => search}}, socket) do
    %{per_page: per_page} = socket.assigns
    total_pages = Users.total_pages(per_page, search)
    socket = assign(socket, page: 1, search: search, update_action: "replace", total_pages: total_pages)
    |> fetch_users()
    {:noreply, socket}
  end
  # handle event end
end
