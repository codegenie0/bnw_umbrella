defmodule BnwDashboardWeb.Reimbursement.Help.HelpLiveReview do
  use BnwDashboardWeb, :live_view

  @impl true
  def mount(_, _, socket) do
    socket = assign(socket,
      review_filter: false,
      review_submission: false,
      review_approval: false,
      review_reports: false)

    {:ok, socket}
  end

  @doc """
  This part of the page uses four handle_events
  All of which do the same thing but for different sections

  Show/Hide filter
  Show/Hide submission
  Show/Hide approval
  Show/Hide reports
  """
  @impl true
  def handle_event("review_filter", _, socket) do
    %{review_filter: review_filter} = socket.assigns
    socket = assign(socket, review_filter: !review_filter)
    {:noreply, socket}
  end

  @impl true
  def handle_event("review_submission", _, socket) do
    %{review_submission: review_submission} = socket.assigns
    socket = assign(socket, review_submission: !review_submission)
    {:noreply, socket}
  end

  @impl true
  def handle_event("review_approval", _, socket) do
    %{review_approval: review_approval} = socket.assigns
    socket = assign(socket, review_approval: !review_approval)
    {:noreply, socket}
  end

  @impl true
  def handle_event("review_reports", _, socket) do
    %{review_reports: review_reports} = socket.assigns
    socket = assign(socket, review_reports: !review_reports)
    {:noreply, socket}
  end
end
