defmodule BnwDashboardWeb.TentativeShip.DefaultRoles.DefaultRolesLive do
  use BnwDashboardWeb, :live_view

  alias BnwDashboardWeb.TentativeShip.DefaultRoles.{
    ChangeDefaultRoleComponent
  }

  alias TentativeShip.{
    Permissions,
    Roles
  }

  defp fetch_roles(socket) do
    permissions = Permissions.list_permissions()
    roles =
      Roles.list_roles(:defaults)
      |> Enum.map(fn r ->
        perm =
          Enum.map(permissions, fn p ->
            active = Enum.any?(r.permissions, &(&1.id == p.id))
            Map.put(p, :active, active)
          end)
        Map.put(r, :permissions, perm)
      end)

    assign(socket, roles: roles)
  end

  @impl true
  def mount(_params, session, socket) do
    socket =
      assign_defaults(session, socket)
      |> assign(socket, app: "Tentative Shipments",
                        page_title: "BNW Dashboard · Tentative Ship · Roles",
                        modal: nil,
                        changeset: nil)

    if connected?(socket), do: Roles.subscribe()
    {:ok, socket}
  end

  # handle params
  @impl true
  def handle_params(%{"change" => "new"} = params, uri, socket) do
    params = Map.delete(params, "change")
    changeset =
      Roles.new_role()
      |> Roles.change_role()

    socket = assign(socket, modal: :change, changeset: changeset)
    handle_params(params, uri, socket)
  end

  @impl true
  def handle_params(%{"change" => role_id} = params, uri, socket) do
    params = Map.delete(params, "change")
    changeset =
      Roles.get_role!(role_id)
      |> Roles.change_role()

    socket = assign(socket, modal: :change, changeset: changeset)
    handle_params(params, uri, socket)
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    socket =
      fetch_roles(socket)
      |> assign(app: "Tentative Shipments",
                page_title: "BNW Dashboard · Tentative Ship · Roles",
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
  def handle_info({[:role, :permission_updated], role_permission}, socket) do
    %{roles: roles} = socket.assigns
    new_roles =
      Enum.map(roles, fn r ->
        cond do
          r.id == role_permission.role_id ->
            perms =
              Enum.map(r.permissions, fn p ->
                cond do
                  p.id == role_permission.permission_id ->
                    Map.put(p, :active, !p.active)
                  true -> p
                end
              end)
            Map.put(r, :permissions, perms)
          true -> r
        end
      end)
    socket = assign(socket, roles: new_roles)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:role, :created], _role}, socket) do
    socket = fetch_roles(socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:role, :updated], role}, socket) do
    %{changeset: changeset, modal: modal} = socket.assigns
    socket = cond do
      modal == :change && changeset.data.id == role.id ->
        assign(socket, changeset: Roles.change_role(role))
      true -> socket
    end
    socket = fetch_roles(socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:role, :deleted], role}, socket) do
    %{changeset: changeset, modal: modal} = socket.assigns
    socket = cond do
      modal == :change && changeset.data.id == role.id ->
        assign(socket, changeset: nil, modal: nil)
      true -> socket
    end
    socket = fetch_roles(socket)

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
    Roles.get_role!(id)
    |> Roles.delete_role()
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, changeset: nil, modal: nil)
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__), replace: true)}
  end

  @impl true
  def handle_event("change_permission", params, socket) do
    %{"permission-id" => p_id, "role-id" => r_id} = params
    Roles.change_permission(r_id, p_id)
    {:noreply, socket}
  end
  # end handle event
end
