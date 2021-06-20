defmodule BnwDashboardWeb.Accounts.Users.UsersLive do
  use BnwDashboardWeb, :live_view

  alias BnwDashboardWeb.Accounts.Users.UserLive
  alias Accounts.Users
  alias BnwDashboardWeb.Accounts.Users.ChangeUserComponent


  defp fetch_users(socket) do
    %{page: page, per_page: per_page, search: search, include_customers: include_customers} = socket.assigns
    users = Users.list_users(include_customers, page, per_page, search)
    assign(socket, users: users)
  end

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(session, socket)
    |> assign(page_title: "BNW Dashboard · Accounts",
              modal: nil,
              changeset: nil,
              app: "Accounts")

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
    include_customers = false
    search = ""
    total_pages = Users.total_pages(include_customers, per_page, search)
    socket = assign(socket, modal: nil,
                            changeset: nil,
                            page: 1,
                            per_page: per_page,
                            search: search,
                            include_customers: include_customers,
                            total_pages: total_pages,
                            update_action: "replace")
    |> fetch_users()
    {:noreply, socket}
  end

  # handle_info
  @impl true
  def handle_info({[:user, :created], updated_user}, socket) do
    %{page: page, total_pages: total_pages} = socket.assigns
    socket = cond do
      page == total_pages ->
        assign(socket, modal: nil, changeset: nil, update_action: "append", users: [updated_user])
      true -> socket
    end
    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket) do
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
      total_pages: total_pages,
      include_customers: include_customers
    } = socket.assigns

    cond do
      page < total_pages ->
        page = page + 1
        users = Users.list_users(include_customers, page, per_page, search)
        socket = assign(socket, update_action: "append", page: page, users: users)
        {:noreply, socket}
      true -> {:noreply, socket}
    end
  end

  @impl true
  def handle_event("search_users", %{"search" => %{"search" => search}}, socket) do
    %{per_page: per_page, include_customers: include_customers} = socket.assigns
    total_pages = Users.total_pages(include_customers, per_page, search)
    socket = assign(socket, page: 1, search: search, update_action: "replace", total_pages: total_pages)
    |> fetch_users()
    {:noreply, socket}
  end

  @impl true
  def handle_event("new", _, socket) do
    changeset =
      Users.new_user()
      |> Users.change_user()
    socket = assign(socket, changeset: changeset, modal: :change_user)
    {:noreply, socket}
  end

  @impl true
  def handle_event("include_customers", _, socket) do
    %{include_customers: include_customers, per_page: per_page, search: search} = socket.assigns
    total_pages = Users.total_pages(!include_customers, per_page, search)
    socket = assign(socket, include_customers: !include_customers, page: 1, update_action: "replace", total_pages: total_pages)
    |> fetch_users()
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, changeset: nil, modal: nil)
    {:noreply, socket}
  end
  # end handle_event
end
