defmodule BnwDashboardWeb.PlugsApp.ProjectedBreakeven.ChangeYardComponent do
  use BnwDashboardWeb, :live_component

  alias PlugsApp.ProjectedBreakevenYards

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("new", %{"new" => plug}, socket) do
    changeset = ProjectedBreakevenYards.new_plug()
      |> ProjectedBreakevenYards.change_plug()
    changeset = ProjectedBreakevenYards.validate(changeset.data, plug)
    if changeset.valid? do
      case ProjectedBreakevenYards.create_or_update_plug(changeset.data, plug) do
        {:ok, _plug} ->
          changeset = ProjectedBreakevenYards.validate(changeset.data, plug)
          {:noreply, assign(socket, changeset: changeset)}
        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    ProjectedBreakevenYards.get_plug_struct(id)
    |> ProjectedBreakevenYards.delete_plug()
    {:noreply, socket}
  end
end
