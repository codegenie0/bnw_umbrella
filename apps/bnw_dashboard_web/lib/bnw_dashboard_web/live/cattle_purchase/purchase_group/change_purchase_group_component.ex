defmodule BnwDashboardWeb.CattlePurchase.PurchaseGroups.ChangePurchaseGroupComponent do
  @moduledoc """
  ### Live view component for the add/update purchase group modal.
  """
  use BnwDashboardWeb, :live_component
  alias CattlePurchase.PurchaseGroups
  alias BnwDashboardWeb.CattlePurchase.PurchaseGroup.PurchaseGroupLive
  def mount(socket) do
    {:ok, socket}
  end
  def handle_event("save", %{"purchase_group" => purchase_group}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = PurchaseGroups.validate(changeset.data, purchase_group)
    if changeset.valid? do
      case PurchaseGroups.create_or_update_purchase_group(changeset.data, purchase_group) do
        {:ok, _purchase_group} ->
          {:noreply, push_patch(socket, to: Routes.live_path(socket, PurchaseGroupLive))}
        {:error, %Ecto.Changeset{} = changest} ->
          {:noreply, assign(socket, changeset: changest)}
      end
      {:noreply, socket}
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end
  def handle_event("validate", %{"purchase_group" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset =
      changeset.data
      |> PurchaseGroups.change_purchase_group(params)
      |> Map.put(:action, :update)
    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end
end
