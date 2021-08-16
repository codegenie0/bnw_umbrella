defmodule BnwDashboardWeb.TentativeShip.Yards.YardsLive do
  use BnwDashboardWeb, :live_view

  alias BnwDashboardWeb.TentativeShip.Yards.{
    ChangeYardComponent,
    Destinations.DestinationsLive,
    Roles.RolesLive,
    Users.UsersLive,
    LotStatusCodes.LotStatusCodesLive,
    Schedules.SchedulesLive,
    Schedules.ScheduleLive,
    SexCodes.SexCodesLive,
    YardNumbers.YardNumbersLive
  }

  alias TentativeShip.{
    Yards
  }

  defp fetch_yards(socket) do
    yards = Yards.list_yards()
    assign(socket, yards: yards)
  end

  @impl true
  def mount(_params, session, socket) do
    socket =
      assign_defaults(session, socket)
      |> assign(socket, app: "Tentative Shipments",
                        page_title: "BNW Dashboard · Tentative Ship · Yards",
                        modal: nil,
                        changeset: nil)

    if connected?(socket), do: Yards.subscribe()
    {:ok, socket}
  end

  # handle params
  @impl true
  def handle_params(%{"modal" => modal, "yard" => yard_id, "id" => id} = params, uri, socket) do
    params = Map.delete(params, "modal")
    y_id = Integer.parse(yard_id)
    id_int = Integer.parse(id)
    socket =
      cond do
        y_id != :error && id_int != :error ->
          {y_id, _} = y_id
          {id_int, _} = id_int
          modal = String.to_atom(modal)
          assign(socket, modal: modal, yard_id: y_id, id: id_int)
        y_id != :error && id == "new" ->
          {y_id, _} = y_id
          modal = String.to_atom(modal)
          assign(socket, modal: modal, yard_id: y_id, id: 0)
        true -> socket
      end
    handle_params(params, uri, socket)
  end

  @impl true
  def handle_params(%{"modal" => modal, "yard" => yard_id} = params, uri, socket) do
    params = Map.delete(params, "modal")
    socket =
      case Integer.parse(yard_id) do
        {y_id, _} ->
          modal = String.to_atom(modal)
          assign(socket, modal: modal, yard_id: y_id)
        _ -> socket
      end
    handle_params(params, uri, socket)
  end

  @impl true
  def handle_params(%{"change" => "new"} = params, uri, socket) do
    params = Map.delete(params, "change")
    changeset =
      Yards.new_yard()
      |> Yards.change_yard()

    socket = assign(socket, modal: :change, changeset: changeset)
    handle_params(params, uri, socket)
  end

  @impl true
  def handle_params(%{"change" => yard_id} = params, uri, socket) do
    params = Map.delete(params, "change")
    changeset =
      Yards.get_yard!(yard_id)
      |> Yards.change_yard()

    socket = assign(socket, modal: :change, changeset: changeset)
    handle_params(params, uri, socket)
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    socket =
      fetch_yards(socket)
      |> assign(app: "Tentative Shipments",
                page_title: "BNW Dashboard · Tentative Ship · Yards",
                modal: Map.get(socket.assigns, :modal),
                changeset: Map.get(socket.assigns, :changeset))
    {:noreply, socket}
  end
  # end handle parsms

  # handle info
  @impl true
  def handle_info({:save, %{modal: modal, yard_id: yard_id}}, socket) do
    socket = assign(socket, modal: modal, changeset: nil, yard_id: yard_id)
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{modal: modal, yard: yard_id}), replace: true)}
  end

  @impl true
  def handle_info({:save, _params}, socket) do
    socket = assign(socket, modal: nil, changeset: nil, yard_id: nil)
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__), replace: true)}
  end

  @impl true
  def handle_info({:schedule, params}, socket) do
    %{id: id, yard_id: yard_id} = params
    modal = "schedule"
    socket = assign(socket, modal: modal, yard_id: yard_id)
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{modal: modal, yard: yard_id, id: id}), replace: true)}
  end

  @impl true
  def handle_info({[:yard, :created], _yard}, socket) do
    socket = fetch_yards(socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:yard, :updated], yard}, socket) do
    %{changeset: changeset, modal: modal} = socket.assigns
    socket = cond do
      modal == :change && changeset.data.id == yard.id ->
        assign(socket, changeset: Yards.change_yard(yard))
      true -> socket
    end
    socket = fetch_yards(socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:yard, :deleted], yard}, socket) do
    %{changeset: changeset, modal: modal} = socket.assigns
    socket = cond do
      modal == :change && changeset.data.id == yard.id ->
        assign(socket, changeset: nil, modal: nil)
      true -> socket
    end
    socket = fetch_yards(socket)

    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end
  # end handle info

  # handle event
  @impl true
  def handle_event("new", _, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{change: :new}), replace: true)}
  end

  @impl true
  def handle_event("edit", %{"id" => id}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{change: id}), replace: true)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    Yards.get_yard!(id)
    |> Yards.delete_yard()
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, changeset: nil, modal: nil, yard_id: nil, id: nil)
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__), replace: true)}
  end

  @impl true
  def handle_event("roles", %{"yard-id" => yard_id}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{yard: yard_id, modal: "roles"}), replace: true)}
  end

  @impl true
  def handle_event("users", %{"yard-id" => yard_id}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{yard: yard_id, modal: "users"}), replace: true)}
  end

  @impl true
  def handle_event("modal", %{"yard-id" => yard_id, "modal" => modal, "id" => id}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{yard: yard_id, modal: modal, id: id}), replace: true)}
  end

  @impl true
  def handle_event("modal", %{"yard-id" => yard_id, "modal" => modal}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{yard: yard_id, modal: modal}), replace: true)}
  end
  # end handle event
end
