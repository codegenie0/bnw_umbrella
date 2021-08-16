defmodule BnwDashboardWeb.PlugsApp.CompanyVehicleMile.ChangeFiscalYearComponent do
  use BnwDashboardWeb, :live_component

  alias PlugsApp.CompanyVehicleMileFiscalYears

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("new", %{"new" => plug}, socket) do
    changeset = CompanyVehicleMileFiscalYears.new_plug()
      |> CompanyVehicleMileFiscalYears.change_plug()
    changeset = CompanyVehicleMileFiscalYears.validate(changeset.data, plug)
    if changeset.valid? do
      case CompanyVehicleMileFiscalYears.create_or_update_plug(changeset.data, plug) do
        {:ok, _plug} ->
          {:noreply, socket}
        {:error, %Ecto.Changeset{} = changest} ->
          {:noreply, assign(socket, changeset: changest)}
      end
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    CompanyVehicleMileFiscalYears.get_plug_struct(id)
    |> CompanyVehicleMileFiscalYears.delete_plug()
    {:noreply, socket}
  end
end
