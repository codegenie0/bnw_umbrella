defmodule BnwDashboardWeb.CattlePurchase.DestinationGroup.DestinationGroupLive do
  use BnwDashboardWeb, :live_view

  alias CattlePurchase.{
    Authorize,
    DestinationGroups
  }

  # alias BnwDashboardWeb.CattlePurchase.DestinationGroup.ChangeDestinationGroupComponent
  alias BnwDashboardWeb.CattlePurchase.Destination.DestinationLive

  defp authenticate(socket) do
    current_user = Map.get(socket.assigns, :current_user)

    cond do
      current_user && Authorize.authorize(current_user, "destination_groups") ->
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
        page_title: "BNW Dashboard · Destination Groups",
        app: "Cattle Purchase",
        destination_groups: DestinationGroups.list_destination_groups(),
        modal: nil,
      )

    # if connected?(socket) do
    #   Sexes.subscribe()
    # end

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
  def handle_event("go-to-destination", params, socket) do
    {id, ""} = Integer.parse(params["id"])

    {:noreply,
     push_redirect(socket, to: Routes.live_path(socket, DestinationLive, id), replace: true)}
  end
end
