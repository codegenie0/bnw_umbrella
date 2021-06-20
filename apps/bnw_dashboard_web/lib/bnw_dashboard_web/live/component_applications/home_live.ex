defmodule BnwDashboardWeb.ComponentApplications.HomeLive do
  use BnwDashboardWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(session, socket)
    |> assign(socket, page_title: "BNW Dashboard · Applications", app: "Applications")
    cond do
      socket.assigns.current_user.it_admin ->
        {:ok, socket}
      true ->
        {:ok, redirect(socket, to: "/")}
    end
  end
end
