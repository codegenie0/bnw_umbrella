defmodule BnwDashboardWeb.TentativeShip.Permissions.ChangePermissionComponent do
  use BnwDashboardWeb, :live_component

  alias TentativeShip.Permissions

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("validate", %{"permission" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset =
      changeset.data
      |> Permissions.change_permission(params)
      |> Map.put(:action, :update)

    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  def handle_event("save", %{"permission" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    case Permissions.create_or_update_permission(changeset.data, params) do
      {:ok, _permission} ->
        send self(), {:save, nil}
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
