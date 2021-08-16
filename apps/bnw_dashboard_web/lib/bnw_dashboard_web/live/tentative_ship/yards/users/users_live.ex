defmodule BnwDashboardWeb.TentativeShip.Yards.Users.UsersLive do
  use BnwDashboardWeb, :live_view

  alias TentativeShip.{
    Roles,
    Users
  }
  alias BnwDashboardWeb.TentativeShip.Yards.Users.UserLive

  defp fetch_users(socket) do
    %{page: page, per_page: per_page, search: search} = socket.assigns
    users = Users.list_users(page, per_page, search)
    assign(socket, users: users)
  end

  defp fetch_roles(socket) do
    %{yard_id: yard_id} = socket.assigns
    roles = Roles.list_roles(yard_id)
    assign(socket, roles: roles)
  end

  @impl true
  def mount(_params, session, socket) do
    %{"parent_pid" => parent_pid, "yard_id" => yard_id} = session
    per_page = 20
    search = ""
    total_pages = Users.total_pages(per_page, search)

    socket =
      socket
      |> assign(
          yard_id: yard_id,
          parent_pid: parent_pid,
          page: 1,
          per_page: per_page,
          search: search,
          total_pages: total_pages,
          update_action: "replace"
        )
      |> fetch_users()
      |> fetch_roles()

    if connected?(socket) do
      Users.subscribe()
      Roles.subscribe()
    end
    {:ok, socket}
  end

  # handle info
  @impl true
  def handle_info({[:user, :updated], user}, socket) do
    %{users: users} = socket.assigns
    user_in = Enum.any?(users, &(user.id == &1.id))
    socket =
      cond do
        (user.active && !user_in) || (!user.active && user_in) -> fetch_users(socket)
        true -> socket
      end
    {:noreply, socket}
  end

  def handle_info({[:role, action], role}, socket) do
    %{yard_id: yard_id} = socket.assigns
    socket =
      cond do
        role.yard_id == yard_id && Enum.member?([:created, :deleted], action) ->
          fetch_roles(socket)
        true -> socket
      end
    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end
  # end hadle info

  # handle event
  @impl true
  def handle_event("load_more", _, socket) do
    %{
      page: page,
      per_page: per_page,
      search: search,
      total_pages: total_pages
    } = socket.assigns

    cond do
      page < total_pages ->
        page = page + 1
        users = Users.list_users(page, per_page, search)
        socket = assign(socket, update_action: "append", page: page, users: users)
        {:noreply, socket}
      true -> {:noreply, socket}
    end
  end

  @impl true
  def handle_event("search_users", %{"search" => %{"search" => search}}, socket) do
    %{per_page: per_page} = socket.assigns
    total_pages = Users.total_pages(per_page, search)
    socket =
      assign(socket, page: 1, search: search, update_action: "replace", total_pages: total_pages)
      |> fetch_users()
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    %{parent_pid: parent_pid} = socket.assigns
    send(parent_pid, {:save, nil})
    {:noreply, socket}
  end
  # end handle event
end
