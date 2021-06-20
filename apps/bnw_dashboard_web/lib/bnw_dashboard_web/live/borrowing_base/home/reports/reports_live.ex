defmodule BnwDashboardWeb.BorrowingBase.Home.Reports.ReportsLive do
  use BnwDashboardWeb, :live_view

  alias BorrowingBase.Reports
  alias BnwDashboardWeb.BorrowingBase.Home.{
    Reports.ReportLive
    #HomeLive,         #unused alias
    #EffectiveDateLive #unused alias
  }

  def fetch_reports(socket) do
    reports =
      Reports.list_reports()
      |> Enum.map(&Reports.change_report(&1))
    assign(socket, reports: reports)
  end

  @impl true
  def mount(_params, session, socket) do
    %{
      "current_user" => current_user,
      "effective_date" => effective_date,
      "yard" => yard,
      "weight_break" => weight_break,
      "parent" => parent
    } = session
    socket =
      fetch_reports(socket)
      |> assign(
        current_user: current_user,
        effective_date: effective_date,
        yard: yard,
        weight_break: weight_break,
        parent: parent
      )
    if connected?(socket), do: Reports.subscribe()
    {:ok, socket}
  end

  # handle info
  @impl true
  def handle_info({[:report, _action], _report}, socket) do
    socket = fetch_reports(socket)
    {:noreply, socket}
  end
  # end handle info

  # handle event
  @impl true
  def handle_event("add", _params, socket) do
    %{reports: reports} = socket.assigns
    new_report =
      Reports.new_report()
      |> Reports.change_report()
    reports = reports ++ [new_report]
    socket = assign(socket, reports: reports)
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    %{parent: parent} = socket.assigns
    send(parent, {:save, nil})
    {:noreply, socket}
  end
  # end handle event
end
