defmodule BnwDashboardWeb.PlugsApp.NbxTrucking.ChangeDepartmentComponent do
  use BnwDashboardWeb, :live_component

  alias PlugsApp.NbxTruckingDepartments

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"nbx_trucking_department" => plug}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = NbxTruckingDepartments.validate(changeset.data, plug)
    if changeset.valid? do
      case NbxTruckingDepartments.create_or_update_plug(changeset.data, plug) do
        {:ok, _plug} ->
          {:noreply, socket}
        {:error, %Ecto.Changeset{} = changest} ->
          {:noreply, assign(socket, changeset: changest)}
      end
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
