defmodule BnwDashboardWeb.TentativeShip.Yards.Roles.RoleLive do
  use BnwDashboardWeb, :live_view

  alias TentativeShip.{
    Roles,
    Permissions,
  }

  defp fetch_permissions(socket = %{assigns: %{changeset: %{data: %{permissions: permissions}}}}) do
    permissions = Permissions.list_permissions()
    |> Enum.map(fn p ->
      Map.put(p, :active, Enum.any?(permissions, &(&1.id == p.id)))
    end)
    assign(socket, permissions: permissions)
  end

  defp fetch_permissions(socket), do: socket

  @impl true
  def mount(_params, %{"role" => role, "yard_id" => yard_id, "id" => id}, socket) do
    changeset = Roles.change_role(role)
    socket =
      socket
      |> assign(changeset: changeset, yard_id: yard_id, view_id: id)
      |> fetch_permissions()
    if connected?(socket), do: Roles.subscribe()
    {:ok, socket}
  end

  # handle info
  @impl true
  def handle_info({[:role, :updated], role}, socket) do
    %{changeset: changeset} = socket.assigns
    socket = cond do
      changeset.data.id == role.id ->
        changeset = Roles.change_role(role)
        socket
        |> assign(changeset: changeset)
        |> fetch_permissions()
      true -> socket
    end
    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end
  # end handle info

  # handle event
  @impl true
  def handle_event("delete", _params, socket) do
    %{changeset: changeset} = socket.assigns
    Roles.delete_role(changeset.data)
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"role" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = Roles.change_role(changeset.data, params)
    |> Map.put(:action, :update)
    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"role" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    case Roles.create_or_update_role(changeset.data, params) do
      {:ok, _role} ->
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, changeset: changeset)
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("change_permission", params, socket) do
    %{changeset: changeset} = socket.assigns
    %{"permission-id" => p_id} = params
    Roles.change_permission("#{changeset.data.id}", p_id)
    {:noreply, socket}
  end
  # end handle event
end
