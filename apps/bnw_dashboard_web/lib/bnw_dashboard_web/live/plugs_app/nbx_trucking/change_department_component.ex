defmodule BnwDashboardWeb.PlugsApp.NbxTrucking.ChangeDepartmentComponent do
  use BnwDashboardWeb, :live_component

  alias PlugsApp.NbxTruckingDepartments

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("new", %{"new" => plug}, socket) do
    changeset = NbxTruckingDepartments.new_plug()
    |> NbxTruckingDepartments.change_plug()
    changeset = NbxTruckingDepartments.validate(changeset.data, plug)
    if changeset.valid? do
      case NbxTruckingDepartments.create_or_update_plug(changeset.data, plug) do
        {:ok, _plug} ->
          changeset = NbxTruckingDepartments.new_plug()
          {:noreply, assign(socket, changeset: changeset)}
        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    NbxTruckingDepartments.get_plug_struct(id)
    |> NbxTruckingDepartments.delete_plug()
    {:noreply, socket}
  end
end
