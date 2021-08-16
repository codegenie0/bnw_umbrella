defmodule BnwDashboardWeb.PlugsApp.FuelUsage.ChangeTypeComponent do
  use BnwDashboardWeb, :live_component

  alias PlugsApp.FuelUsageTypes

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("new", %{"new" => plug}, socket) do
    changeset = FuelUsageTypes.new_plug()
    |> FuelUsageTypes.change_plug()
    changeset = FuelUsageTypes.validate(changeset.data, plug)
    if changeset.valid? do
      case FuelUsageTypes.create_or_update_plug(changeset.data, plug) do
        {:ok, _plug} ->
          changeset = FuelUsageTypes.new_plug()
          {:noreply, assign(socket, changeset: changeset)}
        {:error, %Ecto.Changeset{} = changest} ->
          {:noreply, assign(socket, changeset: changest)}
      end
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    FuelUsageTypes.get_plug_struct(id)
    |> FuelUsageTypes.delete_plug()
    {:noreply, socket}
  end
end
