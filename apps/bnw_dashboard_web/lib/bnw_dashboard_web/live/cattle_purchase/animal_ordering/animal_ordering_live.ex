defmodule BnwDashboardWeb.CattlePurchase.AnimalOrdering.AnimalOrderingLive do
  use BnwDashboardWeb, :live_view

  alias CattlePurchase.{
    Authorize,
    Sexes
  }

  defp authenticate(socket) do
    current_user = Map.get(socket.assigns, :current_user)

    cond do
      current_user && Authorize.authorize(current_user, "sexes") ->
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
        page_title: "BNW Dashboard · Active Sexes",
        app: "Cattle Purchase",
        sex: "active",
        sexes: Sexes.get_active_sexes(),
        modal: nil
      )

    if connected?(socket) do
      Sexes.subscribe()
    end

    case authenticate(socket) do
      true -> {:ok, socket}
      false -> {:ok, redirect(socket, to: "/")}
    end
  end

  @impl true
  def handle_params(_, _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("set-active-sexes", _params, socket) do
    {:noreply,
     assign(socket,
       sex: "active",
       page_title: "BNW Dashboard · Active Sex",
       sexes: Sexes.get_active_sexes()
     )}
  end

  @impl true
  def handle_event("set-inactive-sexes", _params, socket) do
    {:noreply,
     assign(socket,
       sex: "inactive",
       page_title: "BNW Dashboard · Inactive Sex",
       sexes: Sexes.get_inactive_sexes()
     )}
  end
end
