defmodule BnwDashboardWeb.Reimbursement.Update.UpdateLive do
  @moduledoc """
  ### Live view for Reimbursement Update page.
  This document renders and controls the Main user page for the reibursement application
  """

  use BnwDashboardWeb, :live_view

  alias BnwDashboardWeb.Reimbursement.Update.ChangeEntryComponent

  alias BnwDashboardWeb.Reimbursement.ReportComponent.{
    ReportComponent,
    NoReportComponent
  }

  alias Reimbursement.{
    Authorize,
    Entries,
    UserRoles,
    Submissions,
    Users,
    Reports
  }

  # private function that authenticates a user by testing if the current user has access to view the current page.
  defp authenticate(socket) do
    current_user = Map.get(socket.assigns, :current_user)
    cond do
      current_user && Authorize.authorize(current_user, "update") ->
        true
      true ->
        false
    end
  end

  # This function fetches all entries from the database and adds them to the entries variable in the socket returned.
  defp fetch_entries(socket) do
    %{month: month, year: year} = socket.assigns
    {_, st_date} = Date.new(year, month, 01)
    en_date      = Date.end_of_month(st_date)
    entries =
      Entries.list_entries(st_date, en_date)
      |> Enum.map(&(Entries.change_entry(&1))) # replace entry with changest of entry
    assign(socket, entries: entries)
  end

  defp set_up_months(socket) do
    available_months =
      [
        [key: "Jan", value: "1"],
        [key: "Feb", value: "2"],
        [key: "Mar", value: "3"],
        [key: "Apr", value: "4"],
        [key: "May", value: "5"],
        [key: "Jun", value: "6"],
        [key: "Jul", value: "7"],
        [key: "Aug", value: "8"],
        [key: "Sep", value: "9"],
        [key: "Oct", value: "10"],
        [key: "Nov", value: "11"],
        [key: "Dec", value: "12"],
      ]

    IO.puts "{{{{{{{{{{{{{{{{{ months }}}}}}}}}}}}}}}}}"
    IO.inspect available_months
    IO.puts "{{{{{{{{{{{{{{{{{ months }}}}}}}}}}}}}}}}}"
    assign(socket, available_months: available_months)
  end

  defp set_up_years(socket, depth \\ 2) do
    cond do
      depth >= -2 ->
        %{available_years: years} = socket.assigns
        cur_year = Date.utc_today().year

        item = [key: Integer.to_string(cur_year - depth), value: Integer.to_string(cur_year - depth)]
        years = List.insert_at(years, 0, item)

        assign(socket, available_years: years)
          |> set_up_years(depth - 1)
      true ->
        socket
    end
  end

  defp get_submission_status(socket) do
    %{
      current_user: %{id: user},
      month: month,
      year: year
    } = socket.assigns

    %{sub: sub, approved: approved, date: date} = Submissions.get_submission(user, month, year)
    month = case date.month do
              1  -> "Jan"
              2  -> "Feb"
              3  -> "Mar"
              4  -> "Apr"
              5  -> "May"
              6  -> "Jun"
              7  -> "Jul"
              8  -> "Aug"
              9  -> "Sep"
              10 -> "Oct"
              11 -> "Nov"
              _  -> "Dec"
            end
    date = "#{date.day}-#{month}-#{date.year}"
    assign(socket, submitted: sub, approved: approved, date: date)
  end

  defp get_my_reviewer(socket) do
    %{current_user: %{id: user_id}} = socket.assigns
    %{name: name, email: email} = UserRoles.get_reviewer(user_id)

    assign(socket, reviewer_name: name,
                   reviewer_email: email)
  end

  @doc """
  This function is the entry point the live view. This is called when live_component(..., this, ...) is called
  """
  @impl true
  def mount(_, session, socket) do
    cur_date = Date.utc_today()

    socket = assign_defaults(session, socket)
      |> assign(page_title: "BNW Dashboard · Reimbursement Entries",
                modal: nil,
                changeset: nil,
                app: "Reimbursement",
                month: cur_date.month,
                year: cur_date.year,
                available_years: [],
                max_display_length: 128)
      |> fetch_entries()
      |> set_up_months()
      |> set_up_years()
      |> get_submission_status()
      |> get_my_reviewer()

    if connected?(socket) do
      Entries.subscribe()
      Users.subscribe()
      UserRoles.subscribe()
      Submissions.subscribe()
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
  def handle_info({[:entry, :created_or_updated], _}, socket) do
    socket = assign(socket, changeset: nil, modal: nil)
      |> fetch_entries()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:submission, :created_or_updated], _}, socket) do
    socket = assign(socket, changeset: nil, modal: nil)
    |> get_submission_status()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:entry, _], _}, socket) do
    {:noreply, fetch_entries(socket)}
  end

  @impl true
  def handle_info({[:submission, _], _}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:user, :updated], _}, socket) do
    case authenticate(socket) do
      true -> {:noreply, socket}
      false -> {:noreply, redirect(socket, to: "/")}
    end
  end

  @impl true
  def handle_info({[_, _], _}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("report", _params, socket) do
    %{current_user: %{id: user},
      month: month,
      year: year
    } = socket.assigns

    id = Reports.get_primary_report()
    if id > 0 do
      url = Reports.build_url(id, month, year, user)
      socket = assign(socket, modal: :report, url: url)
      {:noreply, socket}
    else
      socket = assign(socket, modal: :no_report)
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, changest: nil, modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    cur = Enum.find(socket.assigns.entries, fn u -> u.data.id == id end)
    Entries.delete_entry(cur.data)
    {:noreply, fetch_entries(socket)}
  end

  @impl true
  def handle_event("edit", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    cur = Enum.find(socket.assigns.entries, fn u -> u.data.id == id end)
    %{radio: radio} = Entries.get_radio(id)
    socket = assign(socket,
      changeset: cur,
      modal: :change_entry,
      radio_selection: false,
      radio: radio)
    {:noreply, socket}
  end

  @impl true
  def handle_event("new", _, socket) do
    changeset =
      Entries.new_entry()
      |> Entries.change_entry()

    %{changes: changes} = changeset
    changes = changes
    |> Map.put(:entry_date, Date.utc_today())
    changeset = changeset
    |> Map.put(:changes, changes)

    socket = assign(socket,
      changeset: changeset,
      modal: :change_entry,
      radio_selection:
      true,
      radio: 1)
    {:noreply, socket}
  end

  @impl true
  def handle_event("search", %{"search" => search}, socket) do
    %{"month" => month,
      "year" => year} = search

    socket = assign(socket,
        month: String.to_integer(month),
        year:  String.to_integer(year))
      |> fetch_entries()
      |> get_submission_status()
    {:noreply, socket}
  end

  @impl true
  def handle_event("submit", _, socket) do
    %{
      current_user: %{id: user},
      month: month,
      year: year,
      submitted: sub
    } = socket.assigns

    Submissions.set_submission(user, month, year, (if sub == 1, do: 0, else: 1))
    socket = get_submission_status(socket)

    {:noreply, socket}
  end

  # end handle_event
end
