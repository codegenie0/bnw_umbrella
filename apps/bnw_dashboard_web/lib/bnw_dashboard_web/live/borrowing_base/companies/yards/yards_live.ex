defmodule BnwDashboardWeb.BorrowingBase.Companies.Yards.YardsLive do
  use BnwDashboardWeb, :live_view

  alias BorrowingBase.Yards
  alias BnwDashboardWeb.BorrowingBase.Companies.{
    CompaniesLive,
    Yards.YardLive
  }

  @impl true
  def mount(_params, %{"company" => company}, socket) do
    yards =
      (Yards.list_yards(company) ++ [Yards.new_yard()])
      |> Enum.map(&Yards.change_yard(&1))
    socket = assign(socket, yards: yards, company: company)
    if connected?(socket), do: Yards.subscribe()
    {:ok, socket}
  end

  # handle info
  @impl true
  def handle_info({[:yard, action], yard}, socket) do
    %{company: company} = socket.assigns
    cond do
      company == yard.company_id && Enum.member?([:updated, :deleted], action) ->
        {:noreply, push_redirect(socket, to: Routes.live_path(socket, CompaniesLive, %{yards: true, company: company}), replace: true)}
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
