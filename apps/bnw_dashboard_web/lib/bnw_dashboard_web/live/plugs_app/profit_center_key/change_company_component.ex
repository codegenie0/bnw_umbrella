defmodule BnwDashboardWeb.PlugsApp.ProfitCenterKey.ChangeCompanyComponent do
  use BnwDashboardWeb, :live_component

  alias PlugsApp.ProfitCenterKeyCompanies

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("new", %{"new" => plug}, socket) do
    changeset = ProfitCenterKeyCompanies.new_plug()
    |> ProfitCenterKeyCompanies.change_plug()
    changeset = ProfitCenterKeyCompanies.validate(changeset.data, plug)
    if changeset.valid? do
      case ProfitCenterKeyCompanies.create_or_update_plug(changeset.data, plug) do
        {:ok, _plug} ->
          changeset = ProfitCenterKeyCompanies.new_plug()
          {:noreply, assign(socket, changeset: changeset)}
        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    ProfitCenterKeyCompanies.get_plug_struct(id)
    |> ProfitCenterKeyCompanies.delete_plug()
    {:noreply, socket}
  end
end
