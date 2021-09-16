defmodule BnwDashboardWeb.CattlePurchase.Purchase.PurchaseCommissionComponent do
  @moduledoc """
  ### Live view component for the add/update purchase modal.
  """
  use BnwDashboardWeb, :live_component
  alias CattlePurchase.{Purchases, Commissions}
  alias BnwDashboardWeb.CattlePurchase.Purchase.PurchaseLive

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"commission" => commission}, socket) do
    %{commission_changeset: commission_changeset} = socket.assigns
    commission_changeset = Commissions.validate(commission_changeset.data, commission)
    if commission_changeset.valid? do
      case Commissions.create_or_update_commission(commission_changeset.data, commission) do
        {:ok, _commission} ->
          {:noreply, push_patch(socket, to: Routes.live_path(socket, PurchaseLive))}
        {:error, %Ecto.Changeset{} = changest} ->
          {:noreply, assign(socket, commission_changeset: changest)}
      end
      {:noreply, socket}
    else
      {:noreply, assign(socket, commission_changeset: commission_changeset)}
    end
  end

  def handle_event("validate", %{"commission" => params}, socket) do
    %{commission_changeset: commission_changeset} = socket.assigns
    commission_changeset =
      commission_changeset.data
      |> Commissions.change_commission(params)
      |> Map.put(:action, :update)

    socket = assign(socket, commission_changeset: commission_changeset)
    {:noreply, socket}
  end
end
