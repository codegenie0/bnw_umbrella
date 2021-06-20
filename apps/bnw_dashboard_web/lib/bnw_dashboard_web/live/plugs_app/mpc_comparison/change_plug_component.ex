defmodule BnwDashboardWeb.PlugsApp.MpcComparison.ChangePlugComponent do
  use BnwDashboardWeb, :live_component

  alias PlugsApp.MpcComparisons

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"mpc_comparison" => plug}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = MpcComparisons.validate(changeset.data, plug)
    if changeset.valid? do
      case MpcComparisons.create_or_update_plug(changeset.data, plug) do
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
