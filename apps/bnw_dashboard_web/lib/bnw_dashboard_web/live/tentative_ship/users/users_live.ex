defmodule BnwDashboardWeb.TentativeShip.Users.UsersLive do
  use BnwDashboardWeb, :live_view

  alias TentativeShip.Users


  defp fetch_users(socket) do
    %{page: page, per_page: per_page, search: search} = socket.assigns
    users = Users.list_users(page, per_page, search)
    assign(socket, users: users)
  end

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(session, socket)
    |> assign(socket, app: "Tentative Shipments",
                      page_title: "BNW Dashboard · Tentative Ship · Users")

    if connected?(socket), do: Users.subscribe()
    cond do
      socket.assigns.current_user.it_admin ->
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
    socket = assign(socket, app: "Tentative Shipments",
                            page_title: "BNW Dashboard · Tentative Ship · Users",
                            page: 1,
                            per_page: per_page,
                            search: search,
                            total_pages: total_pages,
                            update_action: "replace")
    |> fetch_users()
    {:noreply, socket}
  end

  # handle_info
  @impl true
  def handle_info({[:user, :created], _updated_user}, socket) do
    socket = fetch_users(socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:tentative_ship, :set_app_admin], _user_role}, socket) do
    socket = fetch_users(socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info(_params, socket) do
    {:noreply, socket}
  end
  # end handle_info

  # handle_event
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
  def handle_event("change_role", %{"id" => id}, socket) do
    id
    |> String.to_integer()
    |> Users.set_app_admin()
    {:noreply, socket}
  end
  # end handle_event
end
