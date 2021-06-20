defmodule BnwDashboardWeb.PlugsApp.FuelUsage.ChangeDepartmentComponent do
  use BnwDashboardWeb, :live_component

  alias PlugsApp.FuelUsageDepartments

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"fuel_usage_department" => plug}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = FuelUsageDepartments.validate(changeset.data, plug)
    if changeset.valid? do
      case FuelUsageDepartments.create_or_update_plug(changeset.data, plug) do
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
