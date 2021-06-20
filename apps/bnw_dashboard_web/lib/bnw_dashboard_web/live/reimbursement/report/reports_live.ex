defmodule BnwDashboardWeb.Reimbursement.Report.ReportsLive do
  use BnwDashboardWeb, :live_view

  alias BnwDashboardWeb.Reimbursement.Report.ChangeReportComponent

  alias BnwDashboardWeb.Reimbursement.ReportComponent.ReportComponent

  alias Reimbursement.{
    Authorize,
    Reports
  }

  defp authenticate(socket) do
    current_user = Map.get(socket.assigns, :current_user)
    cond do
      current_user && Authorize.authorize(current_user, "reports") ->
        true
      true ->
        false
    end
  end

  defp fetch_entries(socket) do
    reports =
      Reports.list_reports()
      |> Enum.map(&(Reports.change_report(&1))) # replace report with changeset of report

    assign(socket, reports: reports)
  end

  defp check_it_admin(socket) do
    current_user = Map.get(socket.assigns, :current_user)

    assign(socket, current_user: current_user, it_admin: current_user.it_admin)
  end

  @impl true
  def mount(_, session, socket) do
    socket = assign_defaults(session, socket)
      |> assign(page_title: "BNW Dashboard · Reimbursement Report",
                modal: nil,
                changeset: nil,
                app: "Reimbursement",
                max_display_length: 128)
      |> fetch_entries()
      |> check_it_admin()

    if connected?(socket) do
      Reports.subscribe()
    end
    case authenticate(socket) do
      true -> {:ok, socket}
      false -> {:ok, redirect(socket, to: "/")}
    end
  end

  @doc """
  This fixes an error where the page is loaded with a parameter.
  When a button is pressed it puts a '#' in the address bar which fires this function.
  """
  @impl true
  def handle_params(_, _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:report, :created_or_updated], _}, socket) do
    socket = assign(socket, changeset: nil, modal: nil)
    |> fetch_entries()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:report, _], _}, socket) do
    {:noreply, fetch_entries(socket)}
  end

  @impl true
  def handle_info({[:user, :updated], _}, socket) do
    case authenticate(socket) do
      true -> {:noreply, socket}
      false -> {:noreply, redirect(socket, to: "/")}
    end
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("new", _, socket) do
    changeset =
      Reports.new_report()
      |> Reports.change_report()

    socket = assign(socket,
      changeset: changeset,
      modal: :change_report)
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    cur = Enum.find(socket.assigns.reports, fn u -> u.data.id == id end)
    socket = assign(socket,
      changeset: cur,
      modal: :change_report)
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, changest: nil, modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_event("change_active",%{"id" => id}, socket) do
    Reports.set_active(id)
    {:noreply, socket}
  end

  @impl true
  def handle_event("change_primary",%{"id" => id}, socket) do
    Reports.set_primary(id)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    cur = Enum.find(socket.assigns.reports, fn u -> u.data.id == id end)
    Reports.delete_report(cur.data)
    {:noreply, fetch_entries(socket)}
  end

  @impl true
  def handle_event("view_report", %{"id" => id}, socket) do
    %{current_user: %{id: user}} = socket.assigns
    cur_date = Date.utc_today
    url = Reports.build_url(id, cur_date.month, cur_date.year, user)
    socket = assign(socket, modal: :report, url: url)
    {:noreply, socket}
  end
end
