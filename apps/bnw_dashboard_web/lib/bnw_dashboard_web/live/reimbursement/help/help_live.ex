defmodule BnwDashboardWeb.Reimbursement.Help.HelpLive do
  @moduledoc """
  ### Live view for the Reimbursement Help page.
  This page renders a static colapsable HTML help page.
  """

#  TO DO:
#
#  add some definitions.
#    what is an entry
#    what is a reviewer
#
#  default the top section to be expanded

  use BnwDashboardWeb, :live_view

  alias Reimbursement.Authorize

  alias BnwDashboardWeb.Reimbursement.Help.{
    HelpLiveEntries,
    HelpLiveReview,
    HelpLiveRate,
    HelpLiveUsers,
    HelpLiveReports
  }

  alias Reimbursement.UserRoles

  # private function that authenticates a user by testing if the current user
  # has the correct role to view this page
  defp authenticate(socket) do
    current_user = Map.get(socket.assigns, :current_user)
    cond do
      current_user && Authorize.authorize(current_user, "help") ->
        true
      true ->
        false
    end
  end

  # private function that checks which roles the user has to display appropriate help
  defp get_roles(socket) do
    %{current_user: %{id: user_id, it_admin: it_admin}} = socket.assigns
    user   = UserRoles.get_a_role(user_id, "user")     || it_admin
    review = UserRoles.get_a_role(user_id, "reviewer") || it_admin
    report = UserRoles.get_a_role(user_id, "report")   || it_admin
    admin  = UserRoles.get_a_role(user_id, "admin")    || it_admin

    assign(socket, is_user:   user,
                   is_review: review,
                   is_report: report,
                   is_admin:  admin)
  end

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(session, socket)
      |> assign(page_title: "BNW Dashboard · Reimbursement Help",
                app: "Reimbursement",
                draft_number: "Draft 3 7/Jun/2021",
                entries_show: true,
                review_show:  false,
                rate_show:    false,
                users_show:   false,
                reports_show: false)
      |> get_roles()

    %{current_user: %{it_admin: it_admin}} = socket.assigns
    socket = assign(socket, it_admin: it_admin)

    case authenticate(socket) do
      true  ->
        {:ok, socket}
      false ->
        {:ok, redirect(socket, to: "/")}
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
  ### Handle Info
  This page uses one handle info.
  User updated to correct permissions
  """
  @impl true
  def handle_info({[:user, :updated], _}, socket) do
    case authenticate(socket) do
      true  ->
        {:noreply, get_roles(socket)}
      false ->
        {:noreply, redirect(socket, to: "/")}
    end
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end

  @doc """
  This part of the page uses five handle_events
  All of which do the same thing but for different sections

  Show/Hide entries
  Show/Hide review
  Show/Hide rate
  Show/Hide Users
  Show/Hide Reports
  """
  @impl true
  def handle_event("entries_show", _, socket) do
    %{entries_show: entries_show} = socket.assigns
    socket = assign(socket, entries_show: !entries_show)
    {:noreply, socket}
  end

  @impl true
  def handle_event("review_show", _, socket) do
    %{review_show: review_show} = socket.assigns
    socket = assign(socket, review_show: !review_show)
    {:noreply, socket}
  end

  @impl true
  def handle_event("rate_show", _, socket) do
    %{rate_show: rate_show} = socket.assigns
    socket = assign(socket, rate_show: !rate_show)
    {:noreply, socket}
  end

  @impl true
  def handle_event("users_show", _, socket) do
    %{users_show: users_show} = socket.assigns
    socket = assign(socket, users_show: !users_show)
    {:noreply, socket}
  end

  @impl true
  def handle_event("reports_show", _, socket) do
    %{reports_show: reports_show} = socket.assigns
    socket = assign(socket, reports_show: !reports_show)
    {:noreply, socket}
  end
end
