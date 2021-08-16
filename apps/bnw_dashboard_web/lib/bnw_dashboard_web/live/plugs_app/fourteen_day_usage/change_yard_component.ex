defmodule BnwDashboardWeb.PlugsApp.FourteenDayUsage.ChangeYardComponent do
  use BnwDashboardWeb, :live_component

  alias PlugsApp.FourteenDayUsageYards

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("new", %{"new" => plug}, socket) do
    changeset = FourteenDayUsageYards.new_plug()
      |> FourteenDayUsageYards.change_plug()
    changeset = FourteenDayUsageYards.validate(changeset.data, plug)
    if changeset.valid? do
      case FourteenDayUsageYards.create_or_update_plug(changeset.data, plug) do
        {:ok, _plug} ->
          changeset = FourteenDayUsageYards.new_plug()
          {:noreply, assign(socket, changeset: changeset)}
        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    FourteenDayUsageYards.get_plug_struct(id)
    |> FourteenDayUsageYards.delete_plug()
    {:noreply, socket}
  end
end
