defmodule BnwDashboardWeb.PlugsApp.NbxTrucking.ChangePlugComponent do
  use BnwDashboardWeb, :live_component

  alias PlugsApp.NbxTruckings

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"nbx_trucking" => plug}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = NbxTruckings.validate(changeset.data, plug)
    if changeset.valid? do
      case NbxTruckings.create_or_update_plug(changeset.data, plug) do
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
