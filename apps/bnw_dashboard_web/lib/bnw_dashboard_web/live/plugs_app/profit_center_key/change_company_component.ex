defmodule BnwDashboardWeb.PlugsApp.ProfitCenterKey.ChangeCompanyComponent do
  use BnwDashboardWeb, :live_component

  alias PlugsApp.ProfitCenterKeyCompanies

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"profit_center_key_company" => plug}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = ProfitCenterKeyCompanies.validate(changeset.data, plug)
    if changeset.valid? do
      case ProfitCenterKeyCompanies.create_or_update_plug(changeset.data, plug) do
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
