defmodule BnwDashboardWeb.CattlePurchase.Page.PageLive do
  use BnwDashboardWeb, :live_view

  alias CattlePurchase.{
    Authorize
  }

  defp authenticate(socket) do
    current_user = Map.get(socket.assigns, :current_user)

    cond do
      current_user && Authorize.authorize(current_user, "page") ->
        true

      true ->
        false
    end
  end

  @impl true
  def mount(_, session, socket) do
    socket =
      assign_defaults(session, socket)
      |> assign(
        page_title: "Cattle Purchase Page",
        app: "Cattle Purchase"
      )

    if connected?(socket) do
      # subscribe here
    end

    case authenticate(socket) do
      true -> {:ok, socket}
      false -> {:ok, redirect(socket, to: "/")}
    end
  end
end
