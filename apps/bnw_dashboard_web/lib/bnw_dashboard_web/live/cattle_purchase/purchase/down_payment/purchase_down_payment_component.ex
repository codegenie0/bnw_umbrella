defmodule BnwDashboardWeb.CattlePurchase.Purchase.PurchaseDownPaymentComponent do
  @moduledoc """
  ### Live view component for the add/update purchase modal.
  """
  use BnwDashboardWeb, :live_component
  alias CattlePurchase.{Purchases, DownPayments, DownPayment}
  alias BnwDashboardWeb.CattlePurchase.Purchase.PurchaseLive

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"down_payment" => down_payment}, socket) do
    %{
      down_payment_changeset: down_payment_changeset,
      down_payments_in_form: down_payments_in_form
    } = socket.assigns

    {purchase_id, ""} = Integer.parse(down_payment["purchase_id"] || 1)
    down_payment_changeset = DownPayments.validate(down_payment_changeset.data, down_payment)
    down_payments_in_form = format_down_payments(down_payment, down_payments_in_form)

    if is_all_down_payment_valid(down_payments_in_form) do
      down_payments_to_save =
        down_payments_in_form
        |> remove_valid_key_add_purchase_id(purchase_id)
        |> Enum.map(fn down_payment -> DownPayments.validate(%DownPayment{}, down_payment) end)

      case DownPayments.create_multiple_down_payment(down_payments_to_save) do
        {:ok, _commission} ->
          send(socket.assigns.parent_pid, {:down_payments_created, true})

          {:noreply,
           push_patch(socket,
             to:
               Routes.live_path(socket, PurchaseLive,
                 submit_type: "",
                 purchase_id: ""
               )
           )}

        {:error, %Ecto.Changeset{} = changest} ->
          {:noreply,
           assign(socket,
             down_payment_changeset: changest,
             down_payments_in_form: down_payments_in_form
           )}
      end

      {:noreply, socket}
    else
      {:noreply,
       assign(socket,
         down_payment_changeset: down_payment_changeset,
         down_payments_in_form: down_payments_in_form
       )}
    end
  end

  def handle_event("validate", %{"down_payment" => params}, socket) do
    %{down_payments_in_form: down_payments_in_form} = socket.assigns

    socket =
      assign(socket,
        down_payments_in_form: format_down_payments(params, down_payments_in_form)
      )

    {:noreply, socket}
  end

  def handle_event("add_down_payment", _, socket) do
    %{down_payments_in_form: down_payments_in_form} = socket.assigns

    down_payments_in_form =
      down_payments_in_form ++
        [
          %{
            description: "",
            amount: 0,
            date_paid: "",
            locked: "",
            valid: true
          }
        ]

    socket = assign(socket, down_payments_in_form: down_payments_in_form)
    {:noreply, socket}
  end

  def handle_event("delete_down_payment", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    %{down_payments_in_form: down_payments_in_form} = socket.assigns

    down_payments_in_form =
      cond do
        length(down_payments_in_form) > 1 ->
          List.delete_at(down_payments_in_form, id)

        true ->
          down_payments_in_form
      end

    socket = assign(socket, down_payments_in_form: down_payments_in_form)
    {:noreply, socket}
  end

  defp format_down_payments(down_payments_params, down_payments_in_form) do
    down_payments_in_form =
      down_payments_in_form
      |> Enum.with_index()
      |> Enum.map(fn {c, i} ->
        key_description = Integer.to_string(i) <> "_description"
        key_amount = Integer.to_string(i) <> "_amount"
        key_date_paid = Integer.to_string(i) <> "_date_paid"
        key_locked = Integer.to_string(i) <> "_locked"

        down_payment_description =
          if down_payments_params[key_description] != "",
            do: down_payments_params[key_description],
            else: ""

        down_payment_amount =
          if down_payments_params[key_amount] != "",
            do: down_payments_params[key_amount],
            else: ""

        down_payment_date_paid =
          if down_payments_params[key_date_paid] != "",
            do: down_payments_params[key_date_paid],
            else: ""

        down_payment_locked =
          if down_payments_params[key_locked] != "",
            do: down_payments_params[key_locked],
            else: ""

        result = %{
          down_payment_description: down_payment_description,
          down_payment_amount: down_payment_amount,
          down_payment_date_paid: down_payment_date_paid,
          down_payment_locked: down_payment_locked
        }

        valid = check_valid_down_payment(result)
        result = Map.put(result, :valid, valid)
      end)

    down_payments_in_form
  end

  defp check_valid_down_payment(down_payment) do

    if(
      down_payment.down_payment_description != "" && down_payment.down_payment_amount != "" &&
        down_payment.down_payment_amount >= 1 &&
        down_payment.down_payment_date_paid != ""
    ) do
      true
    else
      false
    end
  end

  defp is_all_down_payment_valid(down_payments) do
    down_payments = Enum.filter(down_payments, fn item -> !item.valid end)
    if length(down_payments) >= 1, do: false, else: true
  end

  defp remove_valid_key_add_purchase_id(down_payments, purchase_id) do
    Enum.map(down_payments, fn item ->
      item
      |> Map.delete(:valid)
      |> Map.put(:purchase_id, purchase_id)
    end)
  end
end
