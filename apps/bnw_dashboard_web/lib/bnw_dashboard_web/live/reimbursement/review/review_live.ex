defmodule BnwDashboardWeb.Reimbursement.Review.ReviewLive do
  @moduledoc """
  ### Live view for the Reimbursement Review page.
  This document renders and controls the Review page for the reimbursement application. This page is only accessable to users with the Reviewer role.
  """

  use BnwDashboardWeb, :live_view

  alias BnwDashboardWeb.Reimbursement.ReportComponent.{
    ReportComponent,
    NoReportComponent
  }

  alias Reimbursement.{
    Authorize,
    Submissions,
    UserRoles,
    Users,
    Reports
  }

  # private function that authenticates a user by testing if the current user
  # has the correct role to view this page
  defp authenticate(socket) do
    current_user = Map.get(socket.assigns, :current_user)
    cond do
      current_user && Authorize.authorize(current_user, "review") ->
        true
      true ->
        false
    end
  end

  # private function that pulls users assigned to the current user
  # as reviewees
  defp fetch_users(socket) do
    %{current_user: %{id: cu},
      search: search,
      month: month,
      year: year} = socket.assigns

    users = Users.list_reviewers_users(cu, search)
      |> Enum.filter(fn x ->
        Enum.any?(x.users_roles, &(&1 && &1.role == "active"))
        && Enum.any?(x.users_roles, &(&1 && &1.role == "user"))
      end)
      |> Enum.map(&(%{
                      id: &1.id,
                      name: &1.name,
                      username: &1.username,
                      email: &1.email,
                      submitted: Submissions.get_submission(&1.id, month, year)
                    }))

    assign(socket, users: users)
  end

  # private function that sets up the list of months for the drop down menu
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

    assign(socket, available_months: available_months)
  end

  # private function that recursively sets up the list of years for the drop down menu
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

  # private function to get the previous month and year.
  # this is used because the review page defaults to
  # the previous month.
  defp get_prev_month_year(socket) do
    cur_date = Date.utc_today()

    # there are only two cases for this.
    # January or not January.
    %{month: month, year: year} = case cur_date.month do
      # January -> Last month is December of last year
      1 -> %{month: 12, year: cur_date.year - 1}
      # Not January -> Last month is month - 1 of current year
      _ -> %{month: cur_date.month - 1, year: cur_date.year}
    end

    assign(socket, month: month,
                   year: year)
  end

  @doc """
  Entry point for Review page.
  Set up generic assigns
  Get previous month
  Add users
  Add dates

  Subscribe to Users, UserRoles, and Submissions

  Verify current user
  """
  @impl true
  def mount(_params, session, socket) do
    per_page = 30
    search = ""
    socket =
      # Set up generic assigns
      assign_defaults(session, socket)
      |> assign(page_title: "BNW Dashboard · Reimbursement Review",
                app: "Reimbursement",
                search: search,
                per_page: per_page,
                page: 1,
                available_years: [],
                modal: nil)
      # Get Previous Month
      |> get_prev_month_year()
      # Add Users
      |> fetch_users()
      # Add Dates
      |> set_up_months()
      |> set_up_years()

    # Subscribe to Users, UserRoles, and Submissions
    if connected?(socket) do
      Users.subscribe()
      UserRoles.subscribe()
      Submissions.subscribe()
    end

    # Verify current user
    case authenticate(socket) do
      true  -> {:ok, socket}
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

  @doc """
  Handle info.
  This page has two events that it listens to
  ### submission created or updated
  This is called when a user submits while the reviewer is looking at the page.
  When this happens the users portion is refreshed so that the change is added.
  ### user updated
  This is called when the current users role is updated.
  When the role is updated confirm that this user can still access this page.
  If current user can access this page do nothing.
  If current user cannot access this page redirect to root.
  ### Generic handler to prevent an error.
  This handler does nothing but acknowledges all handle_info pub subs
  """
  ### submission created or updated
  # This is called when a user submits while the reviewer is looking at the page.
  # When this happens the users portion is refreshed so that the change is added.
  @impl true
  def handle_info({[:submission, :created_or_updated], _}, socket) do
    {:noreply, fetch_users(socket)}
  end

  ### user updated
  # This is called when the current users role is updated.
  # When the role is updated confirm that this user can still access this page.
  #   If current user can access this page do nothing.
  #   If current user cannot access this page redirect to root.
  @impl true
  def handle_info({[:user, :updated], _}, socket) do
    case authenticate(socket) do
      true -> {:noreply, socket}
      false -> {:noreply, redirect(socket, to: "/")}
    end
  end

  ### Generic handler to prevent an error.
  # This handler does nothing but acknowledges all handle_info pub subs
  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end

  @doc """
  Handle Event
  This page has 4 handle events that is listens to
  ### Approve
  This call marks a submission as approved.
  When a submission is approved it can no longer be un-submitted.
  A submission can only be approved if it was submitted.
  ### Cancel
  This call is made to close the report modal.
  ### Report
  This call is made to open the report modal.
  ### Search
  This call is made to filter the table by date
  """
  ### Approve
  # This call marks a submission as approved.
  # When a submission is approved it can no longer be un-submitted.
  # A submission can only be approved if it was submitted.
  @impl true
  def handle_event("approve", %{"user" => user, "approved" => approved}, socket) do
    user     = String.to_integer(user)
    approved = String.to_integer(approved)
    %{month: month, year: year} = socket.assigns
    Submissions.approve(user, month, year, approved)
    {:noreply, socket}
  end

  ### Cancel
  # This call is made to close the report modal.
  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, modal: nil)
    {:noreply, socket}
  end

  ### Report
  # This call is made to open the report modal.
  @impl true
  def handle_event("report", %{"user" => user_id}, socket) do
    %{month: month,
      year: year
    } = socket.assigns

    user = Users.get_user(user_id)
    id = Reports.get_primary_report()
    if id > 0 do
      url = Reports.build_url(id, month, year, user_id)
      socket = assign(socket, modal: :report, url: url, user: user)
      {:noreply, socket}
    else
      socket = assign(socket, modal: :no_report)
      {:noreply, socket}
    end
  end

  ### Search
  # This call is made to filter the table by date
  @impl true
  def handle_event("search", %{"search" => search}, socket) do
    %{"month" => month,
      "year"  => year} = search

    socket = assign(socket,
        month: String.to_integer(month),
        year:  String.to_integer(year))
      |> fetch_users()

    {:noreply, socket}
  end
end
