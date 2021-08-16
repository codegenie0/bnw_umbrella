defmodule BnwDashboardWeb.TentativeShip.Permissions.PermissionsLive do
  use BnwDashboardWeb, :live_view

  alias BnwDashboardWeb.TentativeShip.Permissions.{
    ChangePermissionComponent
  }

  alias TentativeShip.{
    Permissions
  }

  defp fetch_permissions(socket) do
    permissions = Permissions.list_permissions()
    assign(socket, permissions: permissions)
  end

  @impl true
  def mount(_params, session, socket) do
    socket =
      assign_defaults(session, socket)
      |> assign(socket, app: "Tentative Shipments",
                        page_title: "BNW Dashboard · Tentative Ship · Permissions",
                        modal: nil,
                        changeset: nil)

    if connected?(socket), do: Permissions.subscribe()
    {:ok, socket}
  end

  # handle params
  @impl true
  def handle_params(%{"change" => "new"} = params, uri, socket) do
    params = Map.delete(params, "change")
    changeset =
      Permissions.new_permission()
      |> Permissions.change_permission()

    socket = assign(socket, modal: :change, changeset: changeset)
    handle_params(params, uri, socket)
  end

  @impl true
  def handle_params(%{"change" => permission_id} = params, uri, socket) do
    params = Map.delete(params, "change")
    changeset =
      Permissions.get_permission!(permission_id)
      |> Permissions.change_permission()

    socket = assign(socket, modal: :change, changeset: changeset)
    handle_params(params, uri, socket)
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    socket =
      fetch_permissions(socket)
      |> assign(app: "Tentative Shipments",
                page_title: "BNW Dashboard · Tentative Ship · Permissions",
                modal: Map.get(socket.assigns, :modal),
                changeset: Map.get(socket.assigns, :changeset))
    {:noreply, socket}
  end
  # end handle parsms

  # handle info
  @impl true
  def handle_info({:save, _params}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:permission, :created], _permission}, socket) do
    socket = fetch_permissions(socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:permission, :updated], permission}, socket) do
    %{changeset: changeset, modal: modal} = socket.assigns
    socket = cond do
      modal == :change && changeset.data.id == permission.id ->
        assign(socket, changeset: Permissions.change_permission(permission))
      true -> socket
    end
    socket = fetch_permissions(socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:permission, :deleted], permission}, socket) do
    %{changeset: changeset, modal: modal} = socket.assigns
    socket = cond do
      modal == :change && changeset.data.id == permission.id ->
        assign(socket, changeset: nil, modal: nil)
      true -> socket
    end
    socket = fetch_permissions(socket)

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
    Permissions.get_permission!(id)
    |> Permissions.delete_permission()
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, changeset: nil, modal: nil)
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__), replace: true)}
  end
  # end handle event
end
