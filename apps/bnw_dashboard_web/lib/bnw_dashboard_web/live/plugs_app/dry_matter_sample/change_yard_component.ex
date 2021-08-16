defmodule BnwDashboardWeb.PlugsApp.DryMatterSample.ChangeYardComponent do
  use BnwDashboardWeb, :live_component

  alias PlugsApp.DryMatterSampleYards

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("new", %{"new" => plug}, socket) do
    changeset = DryMatterSampleYards.new_plug()
      |> DryMatterSampleYards.change_plug()
    changeset = DryMatterSampleYards.validate(changeset.data, plug)
    if changeset.valid? do
      case DryMatterSampleYards.create_or_update_plug(changeset.data, plug) do
        {:ok, _plug} ->
          changeset = DryMatterSampleYards.new_plug()
          {:noreply, assign(socket, changeset: changeset)}
        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    DryMatterSampleYards.get_plug_struct(id)
    |> DryMatterSampleYards.delete_plug()
    {:noreply, socket}
  end
end
