defmodule BnwDashboardWeb.CattlePurchase.PurchaseFlags.ChangePurchaseFlagComponent do
  @moduledoc """
  ### Live view component for the add/update purchase flags modal.
  """
  use BnwDashboardWeb, :live_component
  alias CattlePurchase.PurchaseFlags
  alias BnwDashboardWeb.CattlePurchase.PurchaseFlag.PurchaseFlagLive
  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"purchase_flag" => purchase_flag}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = PurchaseFlags.validate(changeset.data, purchase_flag)
    if changeset.valid? do
      case PurchaseFlags.create_or_update_purchase_flag(changeset.data, purchase_flag) do
        {:ok, _purchase_flag} ->
          {:noreply, push_patch(socket, to: Routes.live_path(socket, PurchaseFlagLive))}
        {:error, %Ecto.Changeset{} = changest} ->
          {:noreply, assign(socket, changeset: changest)}
      end
      {:noreply, socket}
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("validate", %{"purchase_flag" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset =
      changeset.data
      |> PurchaseFlags.change_purchase_flag(params)
      |> Map.put(:action, :update)
    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end
end
