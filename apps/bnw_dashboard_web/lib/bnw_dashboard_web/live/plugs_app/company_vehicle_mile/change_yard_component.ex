defmodule BnwDashboardWeb.PlugsApp.CompanyVehicleMile.ChangeYardComponent do
  use BnwDashboardWeb, :live_component

  alias PlugsApp.CompanyVehicleMileYards

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"company_vehicle_mile_yard" => plug}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = CompanyVehicleMileYards.validate(changeset.data, plug)
    if changeset.valid? do
      case CompanyVehicleMileYards.create_or_update_plug(changeset.data, plug) do
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
