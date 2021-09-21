defmodule BnwDashboardWeb.CattlePurchase.CattleReceive.ChangeCattleReceiveComponent do
  @moduledoc """
  ### Live view component for the add/update purchase modal.
  """
  use BnwDashboardWeb, :live_component

  alias CattlePurchase.{
    CattleReceivings
  }

  alias BnwDashboardWeb.CattlePurchase.CattleReceive.CattleReceiveLive

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"cattle_receiving" => cattle_receiving}, socket) do
    %{changeset: changeset} = socket.assigns
    current_user = Map.get(socket.assigns, :current_user)
    cattle_receiving = Map.put(cattle_receiving, "user_id", current_user.id)
    changeset = CattleReceivings.validate(changeset.data, cattle_receiving)

    if changeset.valid? do
      case CattleReceivings.create_or_update_cattle_receiving(changeset.data, cattle_receiving) do
        {:ok, _purchase} ->
          {:noreply,
           push_patch(socket,
             to: Routes.live_path(socket, CattleReceiveLive, id: socket.assigns.shipment.id)
           )}

        {:error, %Ecto.Changeset{} = _changest} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("validate", %{"cattle_receiving" => cattle_receiving}, socket) do
    %{changeset: changeset} = socket.assigns

    changeset =
      changeset.data
      |> CattleReceivings.change_cattle_receiving(cattle_receiving)
      |> Map.put(:action, :update)

    {:noreply, assign(socket, changeset: changeset)}
  end
end
