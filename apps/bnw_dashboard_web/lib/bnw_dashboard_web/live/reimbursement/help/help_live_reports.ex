defmodule BnwDashboardWeb.Reimbursement.Help.HelpLiveReports do
  use BnwDashboardWeb, :live_view

  @impl true
  def mount(_, %{"it_admin" => it_admin}, socket) do
    socket = assign(socket,
      it_admin: it_admin,
      reports_it: true)

    {:ok, socket}
  end

  @doc """
  This part of the page uses one handle_events
  All of which do the same thing but for different sections

  Show/Hide it
  """
  @impl true
  def handle_event("reports_it", _, socket) do
    %{reports_it: reports_it} = socket.assigns
    socket = assign(socket, reports_it: !reports_it)
    {:noreply, socket}
  end
end
