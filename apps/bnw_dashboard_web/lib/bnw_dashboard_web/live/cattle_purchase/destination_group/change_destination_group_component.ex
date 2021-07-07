defmodule BnwDashboardWeb.CattlePurchase.DestinationGroup.ChangeDestinationGroupComponent do
  @moduledoc """
  ### Live view component for the add/update destination groups modal.
  """
  use BnwDashboardWeb, :live_component
  alias CattlePurchase.DestinationGroups
  alias BnwDashboardWeb.CattlePurchase.DestinationGroup.DestinationGroupLive
  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"destination_group" => destination_group}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = DestinationGroups.validate(changeset.data, destination_group)
    if changeset.valid? do
      case DestinationGroups.create_or_update_destination_group(changeset.data, destination_group) do
        {:ok, _destination_group} ->
          {:noreply, push_patch(socket, to: Routes.live_path(socket, DestinationGroupLive))}
        {:error, %Ecto.Changeset{} = changest} ->
          {:noreply, assign(socket, changeset: changest)}
      end
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("validate", %{"destination_group" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset =
      changeset.data
      |> DestinationGroups.change_destination_group(params)
      |> Map.put(:action, :update)
    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

end
