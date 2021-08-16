defmodule BnwDashboardWeb.PlugsApp.FuelUsage.ChangeYardComponent do
  use BnwDashboardWeb, :live_component

  alias PlugsApp.FuelUsageYards

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("new", %{"new" => plug}, socket) do
    changeset = FuelUsageYards.new_plug()
    |> FuelUsageYards.change_plug()
    changeset = FuelUsageYards.validate(changeset.data, plug)
    if changeset.valid? do
      case FuelUsageYards.create_or_update_plug(changeset.data, plug) do
        {:ok, _plug} ->
          changeset = FuelUsageYards.validate(changeset.data, plug)
          {:noreply, assign(socket, changeset: changeset)}
        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    FuelUsageYards.get_plug_struct(id)
    |> FuelUsageYards.delete_plug()
    {:noreply, socket}
  end
end
