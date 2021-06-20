defmodule BnwDashboardWeb.BorrowingBase.Companies.Users.UsersLive do
  use BnwDashboardWeb, :live_view

  alias BorrowingBase.{
    Roles,
    Users
  }
  alias BnwDashboardWeb.BorrowingBase.Companies.{
    CompaniesLive,
    Users.UserLive
  }

  defp fetch_users(socket) do
    %{
      page: page,
      per_page: per_page,
      search: search,
      current_user: current_user,
      company: company
    } = socket.assigns

    roles =
      cond do
        current_user.it_admin -> Roles.list_roles(company, :include_app_admin)
        true -> Roles.list_roles(company)
      end
    users = Users.list_users(page, per_page, search)
    assign(socket, users: users, roles: roles)
  end

  @impl true
  def mount(_params, %{"company" => company, "current_user" => current_user}, socket) do
    page = 1
    per_page = 20
    search = ""
    socket =
      assign(socket, company: company,
                     current_user: current_user,
                     page: page,
                     per_page: per_page,
                     search: search,
                     total_pages: Users.total_pages(per_page, search),
                     update_action: "replace")
      |> fetch_users()
    if connected?(socket) do
      Roles.subscribe()
      Users.subscribe()
    end
    {:ok, socket}
  end

  # handle info
  @impl true
  def handle_info({[:role, _action], role}, socket) do
    %{company: company} = socket.assigns
    cond do
      company == role.company_id ->
        {:noreply, push_redirect(socket, to: Routes.live_path(socket, CompaniesLive, %{users: true, company: company}), replace: true)}
      true ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end
  # end hadle info

  # handle event
  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, changeset: nil, modal: nil)
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, CompaniesLive), replace: true)}
  end

  def handle_event("search_users", %{"search" => %{"search" => search}}, socket) do
    %{per_page: per_page} = socket.assigns
    page = 1
    users = Users.list_users(page, per_page, search)
    total_pages = Users.total_pages(per_page, search)
    socket = assign(socket, users: users, page: page, total_pages: total_pages, update_action: "replace")
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
  # end handle event
end
