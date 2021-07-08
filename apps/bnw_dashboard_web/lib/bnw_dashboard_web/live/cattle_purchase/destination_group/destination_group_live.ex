defmodule BnwDashboardWeb.CattlePurchase.DestinationGroup.DestinationGroupLive do
  use BnwDashboardWeb, :live_view

  alias CattlePurchase.{
    Authorize,
    DestinationGroups
  }

  alias BnwDashboardWeb.CattlePurchase.DestinationGroup.ChangeDestinationGroupComponent
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
        destination_groups: DestinationGroups.list_destination_groups,
        modal: nil
      )

    if connected?(socket) do
      DestinationGroups.subscribe()
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
  def handle_event("new", _, socket) do
    changeset = DestinationGroups.new_destination_group()
    socket = assign(socket, changeset: changeset, modal: :change_destination_group)
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    changeset =
          Enum.find(socket.assigns.destination_groups, fn pg -> pg.id == id end )
          |>DestinationGroups.change_destination_group()
    socket = assign(socket, changeset: changeset, modal: :change_destination_group)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    Enum.find(socket.assigns.destination_groups, fn pg -> pg.id == id end )
    |>DestinationGroups.delete_destination_group()
    {:noreply, socket}
  end

  @impl true
  def handle_event("go-to-destination", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    {:noreply,
     push_redirect(socket, to: Routes.live_path(socket, DestinationLive, id), replace: true)}
  end

  @impl true
  def handle_info({[:destination_groups, :created_or_updated], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
    {:noreply, assign(socket, destination_groups: DestinationGroups.list_destination_groups() )}
  end

  @impl true
  def handle_info({[:destination_groups, :deleted], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
    {:noreply, assign(socket, destination_groups: DestinationGroups.list_destination_groups() )}
  end
end
