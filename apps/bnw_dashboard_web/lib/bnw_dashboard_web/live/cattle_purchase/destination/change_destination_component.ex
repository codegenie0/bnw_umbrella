defmodule BnwDashboardWeb.CattlePurchase.Destination.ChangeDestinationComponent do
  @moduledoc """
  ### Live view component for the add/update purchase types modal.
  """
  use BnwDashboardWeb, :live_component
  alias CattlePurchase.Destinations
  alias BnwDashboardWeb.CattlePurchase.Destination.DestinationLive

  def mount(socket) do
    IO.puts("----sss-")
    {:ok, socket}
  end

  def handle_event("save", %{"destination" => destination}, socket) do
    %{changeset: changeset, parent_id: parent_id} = socket.assigns
    changeset = Destinations.validate(changeset.data, destination)

    if changeset.valid? do
      case Destinations.create_or_update_destination(changeset.data, destination) do
        {:ok, _destination} ->
          {:noreply, push_patch(socket, to: Routes.live_path(socket, DestinationLive, parent_id))}

        {:error, %Ecto.Changeset{} = changest} ->
          {:noreply, assign(socket, changeset: changest)}
      end

      {:noreply, socket}
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("validate", %{"destination" => params}, socket) do
    %{changeset: changeset} = socket.assigns

    changeset =
      changeset.data
      |> Destinations.change_destination(params)
      |> Map.put(:action, :update)

    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end
end
