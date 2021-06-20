defmodule BnwDashboardWeb.PlugsApp.Template.ChangePlugComponent do
  use BnwDashboardWeb, :live_component

  alias PlugsApp.Templates

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"template" => plug}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = Templates.validate(changeset.data, plug)
    if changeset.valid? do
      case Templates.create_or_update_plug(changeset.data, plug) do
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
