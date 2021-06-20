defmodule BnwDashboardWeb.PlugsApp.CompanyVehicleMile.ChangePlugComponent do
  use BnwDashboardWeb, :live_component

  alias PlugsApp.CompanyVehicleMiles

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"company_vehicle_mile" => plug}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = CompanyVehicleMiles.validate(changeset.data, plug)
    if changeset.valid? do
      case CompanyVehicleMiles.create_or_update_plug(changeset.data, plug) do
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
