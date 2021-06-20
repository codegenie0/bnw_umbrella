defmodule BnwDashboardWeb.Reimbursement.Users.UsersLive do
  @moduledoc """
  ### Live view for the OCB report users page.
  This document renders the administrative OCB page. Allowing administrators to add and remove users while allowing IT to add and remove Admins and users
  """
  use BnwDashboardWeb, :live_view

  alias BnwDashboardWeb.Reimbursement.Users.{
    UserLive,
    AddUsers.UsersLive
  }
  alias Reimbursement.{
    Authorize,
    Roles,
    Users,
    UserRoles
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

    users = Users.list_active_users(page, per_page, search)
    assign(socket, users: users)
  end

  defp fetch_roles(socket) do
    roles =
      Roles.list_roles()
      |> Enum.map(fn r ->
           %{name: r.name, desc: r.desc}
         end)
    assign(socket, roles: roles)
  end

  def fetch_reviewers(socket) do
    reviewers =
      UserRoles.list_reviewers()
      |> Enum.map(&([key: &1.name, value: &1.id]))

    assign(socket, reviewers: reviewers)
  end

  @doc """
  This function is the entry point the live view. This is called when live_component(..., this, ...) is called
  """
  @impl true
  def mount(_params, session, socket) do
    per_page = 20
    search = ""
    socket =
      assign_defaults(session, socket)
      |> assign(page_title: "BNW Dashboard · Reimbursement Users",
                app: "Reimbursement",
                update_action: "replace",
                page: 1,
                per_page: per_page,
                total_pages: Users.total_active_pages(per_page, search),
                search: search,
                modal: nil)
      |> fetch_users()
      |> fetch_roles()
      |> fetch_reviewers()

    if connected?(socket) do
      Users.subscribe()
      UserRoles.subscribe()
    end
    case authenticate(socket) do
      true -> {:ok, socket}
      false -> {:ok, redirect(socket, to: "/")}
    end
  end

  @doc """
  This fixes an error where the page is loaded with a parameter.
  When a button is pressed it puts a '#' in the address bar which fires this function.
  """
  @impl true
  def handle_params(_, _, socket) do
    {:noreply, socket}
  end

  # handle info
  @doc """
  Handle when a user is updated so that if their permissions are updated they will be evicted from the application and the side bar will update with accordingly to their new status.
  """
  @impl true
  def handle_info({[:user, :updated], _customer}, socket) do
    case authenticate(socket) do
      true ->
        socket = fetch_users(socket)
        {:noreply, socket}
      false ->
        {:noreply, redirect(socket, to: "/")}
    end
  end

  @impl true
  def handle_info({:cancel, _params}, socket) do
    socket = assign(socket, modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket) do
    case authenticate(socket) do
      true -> {:noreply, socket}
      false -> {:ok, redirect(socket, to: "/")}
    end
  end
  # handle info end

  # handle event
  @doc """
  Handle when a user is updated to commit the new role to database and broadcast their new role information.

  Handle when an admin scrolls the user page far enough to load in more users.

  Handle when an admin searches for a certain user.
  """

  @impl true
  def handle_event("load_more", _, socket) do
    %{page: page, per_page: per_page, search: search, total_pages: total_pages} = socket.assigns
    socket = cond do
      page < total_pages ->
        page = page + 1
        users = Users.list_active_users(page, per_page, search)
        assign(socket, update_action: "append", page: page, users: users)
      true -> socket
    end
    {:noreply, socket}
  end

  def handle_event("search", %{"search" => %{"search" => search}}, socket) do
    %{per_page: per_page} = socket.assigns
    page = 1
    total_pages = Users.total_active_pages(per_page, search)
    socket = assign(socket, page: page, search: search, total_pages: total_pages, update_action: "replace")
    |> fetch_users()

    {:noreply, socket}
  end

  def handle_event("add_user", _, socket) do
    socket = assign(socket, modal: :add_user)
    {:noreply, socket}
  end

  def handle_event("cancel", _, socket) do
    socket = assign(socket, modal: nil)
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__), replace: true)}
  end

  # handle event end
end
