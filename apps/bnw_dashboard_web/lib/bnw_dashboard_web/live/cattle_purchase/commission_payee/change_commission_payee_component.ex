defmodule BnwDashboardWeb.CattlePurchase.CommissionPayees.ChangeCommissionPayeeComponent do
  @moduledoc """
  ### Live view component for the add/update purchase types modal.
  """
  use BnwDashboardWeb, :live_component
  alias CattlePurchase.CommissionPayees
  alias BnwDashboardWeb.CattlePurchase.CommissionPayee.CommissionPayeeLive

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"commission_payee" => commission_payee}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = CommissionPayees.validate(changeset.data, commission_payee)

    if changeset.valid? do
      case CommissionPayees.create_or_update_commission_payee(changeset.data, commission_payee) do
        {:ok, _commission_payee} ->
          {:noreply, push_patch(socket, to: Routes.live_path(socket, CommissionPayeeLive))}

        {:error, %Ecto.Changeset{} = changest} ->
          {:noreply, assign(socket, changeset: changest)}
      end

      {:noreply, socket}
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("validate", %{"commission_payee" => params}, socket) do
    %{changeset: changeset} = socket.assigns

    changeset =
      changeset.data
      |> CommissionPayees.change_commission_payee(params)
      |> Map.put(:action, :update)

    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end
end
