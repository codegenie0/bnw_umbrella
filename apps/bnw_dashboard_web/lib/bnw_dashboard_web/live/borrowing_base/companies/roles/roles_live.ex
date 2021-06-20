defmodule BnwDashboardWeb.BorrowingBase.Companies.Roles.RolesLive do
  use BnwDashboardWeb, :live_view

  alias BorrowingBase.Roles
  alias BnwDashboardWeb.BorrowingBase.Companies.{
    CompaniesLive,
    Roles.RoleLive
  }

  @impl true
  def mount(_params, %{"company" => company}, socket) do
    roles =
      (Roles.list_roles(company) ++ [Roles.new_role()])
      |> Enum.map(&Roles.change_role(&1))
    socket = assign(socket, roles: roles, company: company)
    if connected?(socket), do: Roles.subscribe()
    {:ok, socket}
  end

  # handle info
  @impl true
  def handle_info({[:role, action], role}, socket) do
    %{company: company} = socket.assigns
    cond do
      company == role.company_id && Enum.member?([:updated, :deleted], action) ->
        {:noreply, push_redirect(socket, to: Routes.live_path(socket, CompaniesLive, %{roles: true, company: company}), replace: true)}
      true ->
        {:noreply, socket}
    end
  end
  # end hadle info

  # handle event
  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, changeset: nil, modal: nil)
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, CompaniesLive), replace: true)}
  end
  # end handle event
end
