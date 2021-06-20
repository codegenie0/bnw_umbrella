defmodule BnwDashboardWeb.CustomerAccess.Users.UsersLive do
  use BnwDashboardWeb, :live_view

  alias BnwDashboardWeb.CustomerAccess.Users.UserLive
  alias CustomerAccess.{
    Authorize,
    Roles,
    Users
  }

  defp fetch_users(socket) do
    %{page: page, per_page: per_page, search: search} = socket.assigns
    roles =
      Roles.list_roles()
      |> Enum.map(&(&1.name))
    users = Users.list_users(page, per_page, search)
    assign(socket, users: users, roles: roles)
  end

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(session, socket)
    |> assign(socket, page_title: "BNW Dashboard · Customer Access Users", app: "Customer Access")

    current_user = Map.get(socket.assigns, :current_user)

    if connected?(socket), do: Users.subscribe()
    cond do
      current_user && Authorize.authorize(current_user, "users") ->
        {:ok, socket}
      true ->
        {:ok, redirect(socket, to: "/")}
    end
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    per_page = 20
    search = ""
    total_pages = Users.total_pages(per_page, search)
    socket =
      socket
      |> assign(page_title: "BNW Dashboard · Customer Access Users",
                app: "Customer Access",
                update_action: "replace",
                page: 1,
                per_page: per_page,
                search: search,
                total_pages: total_pages)
      |> fetch_users()

    {:noreply, socket}
  end

  # handle info
  @impl true
  def handle_info({[:user, :updated], _customer}, socket) do
    {:noreply, fetch_users(socket)}
  end
  # handle info end

  # handle event
  @impl true
  def handle_event("change_role", %{"role" => role, "user" => user}, socket) do
    Users.change_role(user, role)
    {:noreply, socket}
  end

  @impl true
  def handle_event("load_more", _, socket) do
    %{page: page, per_page: per_page, search: search, total_pages: total_pages} = socket.assigns
    socket = cond do
      page < total_pages ->
        page = page + 1
        users = Users.list_users(page, per_page, search)
        assign(socket, update_action: "append", page: page, users: users)
      true -> socket
    end
    {:noreply, socket}
  end

  def handle_event("search", %{"search" => %{"search" => search}}, socket) do
    %{per_page: per_page} = socket.assigns
    total_pages = Users.total_pages(per_page, search)
    socket = assign(socket, page: 1, search: search, update_action: "replace", total_pages: total_pages)
    |> fetch_users()
    {:noreply, socket}
  end
  # handle event end
end
