defmodule BnwDashboardWeb.PlugsApp.FuelUsage.ChangeDepartmentComponent do
  use BnwDashboardWeb, :live_component

  alias PlugsApp.FuelUsageDepartments

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("new", %{"new" => plug}, socket) do
    changeset = FuelUsageDepartments.new_plug()
    |> FuelUsageDepartments.change_plug()
    changeset = FuelUsageDepartments.validate(changeset.data, plug)
    if changeset.valid? do
      case FuelUsageDepartments.create_or_update_plug(changeset.data, plug) do
        {:ok, _plug} ->
          changeset = FuelUsageDepartments.new_plug()
          {:noreply, assign(socket, changeset: changeset)}
        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    FuelUsageDepartments.get_plug_struct(id)
    |> FuelUsageDepartments.delete_plug()
    {:noreply, socket}
  end
end
