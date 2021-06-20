defmodule BnwDashboardWeb.Reimbursement.Help.HelpLiveRate do
  use BnwDashboardWeb, :live_view

  @impl true
  def mount(_, _, socket) do
    socket = assign(socket,
      rate_new: false,
      rate_edit: false,
      rate_delete: false,
      rate_archive: false,
      rate_propagation: false)

    {:ok, socket}
  end

  @doc """
  This part of the page uses five handle_events
  All of which do the same thing but for different sections

  Show/Hide new
  Show/Hide edit
  Show/Hide delete
  Show/Hide archive
  Show/Hide propagation
  """
  @impl true
  def handle_event("rate_new", _, socket) do
    %{rate_new: rate_new} = socket.assigns
    socket = assign(socket, rate_new: !rate_new)
    {:noreply, socket}
  end

  @impl true
  def handle_event("rate_edit", _, socket) do
    %{rate_edit: rate_edit} = socket.assigns
    socket = assign(socket, rate_edit: !rate_edit)
    {:noreply, socket}
  end

  @impl true
  def handle_event("rate_delete", _, socket) do
    %{rate_delete: rate_delete} = socket.assigns
    socket = assign(socket, rate_delete: !rate_delete)
    {:noreply, socket}
  end

  @impl true
  def handle_event("rate_archive", _, socket) do
    %{rate_archive: rate_archive} = socket.assigns
    socket = assign(socket, rate_archive: !rate_archive)
    {:noreply, socket}
  end

  @impl true
  def handle_event("rate_propagation", _, socket) do
    %{rate_propagation: rate_propagation} = socket.assigns
    socket = assign(socket, rate_propagation: !rate_propagation)
    {:noreply, socket}
  end
end
