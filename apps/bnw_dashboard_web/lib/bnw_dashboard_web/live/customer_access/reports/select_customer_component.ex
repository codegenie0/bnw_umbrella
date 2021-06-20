defmodule BnwDashboardWeb.CustomerAccess.Reports.SelectCustomerComponent do
  use BnwDashboardWeb, :live_component

  alias BnwDashboardWeb.CustomerAccess.Reports.ReportsLive

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("search_customers", %{"search" => %{"search" => search}}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, ReportsLive, %{select_customer: true, search: search}), replace: true)}
  end

  def handle_event("select_customer", %{"customer" => customer}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, ReportsLive, %{customer: customer}), replace: true)}
  end
end
