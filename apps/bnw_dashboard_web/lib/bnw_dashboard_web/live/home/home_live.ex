defmodule BnwDashboardWeb.Home.HomeLive do
  use BnwDashboardWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(session, socket)
    |> assign(socket, page_title: "BNW Dashboard · Home")
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    %{current_user: current_user} = socket.assigns
    socket = cond do
      current_user.customer ->
        assign(socket, app: "Customer Access", page_title: "BNW Dashboard · Home")
      true ->
        assign(socket, page_title: "BNW Dashboard · Home")
    end
    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end
end
