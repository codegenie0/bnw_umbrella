defmodule BnwDashboardWeb.PlugsApp.CompanyVehicleMile.ChangeYardComponent do
  use BnwDashboardWeb, :live_component

  alias PlugsApp.CompanyVehicleMileYards

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("new", %{"new" => plug}, socket) do
    changeset = CompanyVehicleMileYards.new_plug()
      |> CompanyVehicleMileYards.change_plug()
    changeset = CompanyVehicleMileYards.validate(changeset.data, plug)
    if changeset.valid? do
      case CompanyVehicleMileYards.create_or_update_plug(changeset.data, plug) do
        {:ok, _plug} ->
          changeset = CompanyVehicleMileYards.new_plug()
          {:noreply, assign(socket, changeset: changeset)}
        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    CompanyVehicleMileYards.get_plug_struct(id)
    |> CompanyVehicleMileYards.delete_plug()
    {:noreply, socket}
  end
end
