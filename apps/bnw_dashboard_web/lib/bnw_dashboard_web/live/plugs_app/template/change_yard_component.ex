defmodule BnwDashboardWeb.PlugsApp.Template.ChangeYardComponent do
  use BnwDashboardWeb, :live_component

  alias PlugsApp.TemplateYards

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("new", %{"new" => plug}, socket) do
    changeset = TemplateYards.new_plug()
      |> TemplateYards.change_plug()
    changeset = TemplateYards.validate(changeset.data, plug)
    if changeset.valid? do
      case TemplateYards.create_or_update_plug(changeset.data, plug) do
        {:ok, _plug} ->
          changeset = TemplateYards.new_plug()
          {:noreply, assign(socket, changeset: changeset)}
        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    TemplateYards.get_plug_struct(id)
    |> TemplateYards.delete_plug()
    {:noreply, socket}
  end
end
