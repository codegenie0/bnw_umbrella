defmodule BnwDashboardWeb.CattlePurchase.Purchase.PurchaseDownPaymentComponent do
  @moduledoc """
  ### Live view component for the add/update purchase modal.
  """
  use BnwDashboardWeb, :live_component
  alias CattlePurchase.{Purchases, DownPayments}
  alias BnwDashboardWeb.CattlePurchase.Purchase.PurchaseLive

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"down_payment" => down_payment}, socket) do
    %{down_payment_changeset: down_payment_changeset} = socket.assigns
    down_payment_changeset = DownPayments.validate(down_payment_changeset.data, down_payment)

    if down_payment_changeset.valid? do
      case DownPayments.create_or_update_down_payment(down_payment_changeset.data, down_payment) do
        {:ok, _down_payment} ->
          send(socket.assigns.parent_pid, {:down_payment_created, true})

          {:noreply,
           push_patch(socket,
             to:
               Routes.live_path(socket, PurchaseLive,
                 submit_type: "",
                 purchase_id: ""
               )
           )}

        {:error, %Ecto.Changeset{} = changest} ->
          {:noreply, assign(socket, down_payment_changeset: changest)}
      end

      {:noreply, socket}
    else
      {:noreply, assign(socket, down_payment_changeset: down_payment_changeset)}
    end
  end

  def handle_event("validate", %{"down_payment" => params}, socket) do
    %{down_payment_changeset: down_payment_changeset} = socket.assigns

    down_payment_changeset =
      down_payment_changeset.data
      |> DownPayments.change_down_payment(params)
      |> Map.put(:action, :update)

    socket = assign(socket, down_payment_changeset: down_payment_changeset)
    {:noreply, socket}
  end
end
