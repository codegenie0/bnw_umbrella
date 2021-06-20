defmodule BnwDashboardWeb.Reimbursement.Users.AddUsers.UsersLive do
  use BnwDashboardWeb, :live_view

  alias Reimbursement.{
    UserRoles,
    Users,
    Roles
  }
  alias BnwDashboardWeb.Reimbursement.Users.AddUsers.{
    UserLive
  }

  defp fetch_users(socket) do
    %{
      page: page,
      per_page: per_page,
      search: search,
    } = socket.assigns

    roles = Roles.list_roles
    users = Users.list_all_users(page, per_page, search)
    assign(socket, users: users, roles: roles)
  end

  @impl true
  def mount(_params, %{"current_user" => current_user,
                       "parent" => parent},
      socket) do
    page = 1
    per_page = 20
    search = ""
    socket =
      assign(socket, current_user: current_user,
                     page: page,
                     per_page: per_page,
                     search: search,
                     total_pages: Users.total_pages(per_page, search),
                     update_action: "append",
                     parent: parent)
      |> fetch_users()
    if connected?(socket) do
      UserRoles.subscribe()
      Users.subscribe()
    end
    {:ok, socket}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end
  # end hadle info

  # handle event
  @impl true
  def handle_event("cancel", _, socket) do
    %{parent: parent} = socket.assigns
    send(parent, {:cancel, nil})
    {:noreply, socket}
  end

  def handle_event("search_users", %{"search" => %{"search" => search}}, socket) do
    %{per_page: per_page} = socket.assigns
    page = 1
    total_pages = Users.total_pages(per_page, search)
    socket = assign(socket, page: page, search: search, total_pages: total_pages, update_action: "replace")
    |> fetch_users()
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
        users = Users.list_all_users(page, per_page, search)
        socket = assign(socket, update_action: "append", page: page, users: users)
        {:noreply, socket}
    end
  end

  # end handle event
end
