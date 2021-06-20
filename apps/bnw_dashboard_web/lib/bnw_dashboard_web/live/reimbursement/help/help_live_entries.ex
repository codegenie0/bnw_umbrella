defmodule BnwDashboardWeb.Reimbursement.Help.HelpLiveEntries do
  use BnwDashboardWeb, :live_view

  @impl true
  def mount(_, _, socket) do
    socket = assign(socket,
      entries_new: false,
      entries_edit: false,
      entries_delete: false,
      entries_submission: false,
      entries_approval: false,
      entries_reports: false)

    {:ok, socket}
  end

  @doc """
  This part of the page uses six handle_events
  All of which do the same thing but for different sections

  Show/Hide new
  Show/Hide edit
  Show/Hide delete
  Show/Hide submission
  Show/Hide approval
  Show/Hide report
  """
  @impl true
  def handle_event("entries_new", _, socket) do
    %{entries_new: entries_new} = socket.assigns
    socket = assign(socket, entries_new: !entries_new)
    {:noreply, socket}
  end

  @impl true
  def handle_event("entries_edit", _, socket) do
    %{entries_edit: entries_edit} = socket.assigns
    socket = assign(socket, entries_edit: !entries_edit)
    {:noreply, socket}
  end

  @impl true
  def handle_event("entries_delete", _, socket) do
    %{entries_delete: entries_delete} = socket.assigns
    socket = assign(socket, entries_delete: !entries_delete)
    {:noreply, socket}
  end

  @impl true
  def handle_event("entries_submission", _, socket) do
    %{entries_submission: entries_submission} = socket.assigns
    socket = assign(socket, entries_submission: !entries_submission)
    {:noreply, socket}
  end

  @impl true
  def handle_event("entries_approval", _, socket) do
    %{entries_approval: entries_approval} = socket.assigns
    socket = assign(socket, entries_approval: !entries_approval)
    {:noreply, socket}
  end

  @impl true
  def handle_event("entries_reports", _, socket) do
    %{entries_reports: entries_reports} = socket.assigns
    socket = assign(socket, entries_reports: !entries_reports)
    {:noreply, socket}
  end
end
