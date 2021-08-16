defmodule BnwDashboardWeb.TentativeShip.DefaultRoles.ChangeDefaultRoleComponent do
  use BnwDashboardWeb, :live_component

  alias TentativeShip.Roles

  def handle_event("validate", %{"role" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset =
      changeset.data
      |> Roles.change_role(params)
      |> Map.put(:action, :update)

    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  def handle_event("save", %{"role" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    case Roles.create_or_update_role(changeset.data, params) do
      {:ok, _role} ->
        send self(), {:save, nil}
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
