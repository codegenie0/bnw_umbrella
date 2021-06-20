defmodule BnwDashboardWeb.PlugsApp.ProjectedBreakeven.ChangePlugComponent do
  use BnwDashboardWeb, :live_component

  alias PlugsApp.ProjectedBreakevens

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"projected_breakeven" => plug}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = ProjectedBreakevens.validate(changeset.data, plug)
    if changeset.valid? do
      case ProjectedBreakevens.create_or_update_plug(changeset.data, plug) do
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
