defmodule BnwDashboardWeb.CattlePurchase.Purchase.PurchaseDownPaymentComponent do
  @moduledoc """
  ### Live view component for the add/update purchase modal.
  """
  use BnwDashboardWeb, :live_component

  alias CattlePurchase.{
    Purchases,
    DownPayments,
    DownPayment,
    PurchaseDetail,
    PurchaseDetails,
    Repo,
    PurchaseSellers,
    PurchaseSeller,
    PurchasePayees,
    PurchasePayee,
    Commission,
    Commissions
  }

  alias BnwDashboardWeb.CattlePurchase.Purchase.PurchaseLive

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"down_payment" => down_payment}, socket) do
    %{
      down_payment_changeset: down_payment_changeset,
      down_payments_in_form: down_payments_in_form,
      down_payment_edit_phase: down_payment_edit_phase,
      down_payments_from_db: down_payments_from_db
    } = socket.assigns

    %{"button" => button} = down_payment

    down_payment_changeset = DownPayments.validate(down_payment_changeset.data, down_payment)
    down_payments_in_form = format_down_payments(down_payment, down_payments_in_form)

    if is_all_down_payment_valid(down_payments_in_form) do
      if button == "Next" do
        ""
      else
        down_payments_to_save =
          if down_payment_edit_phase do
            {purchase_id, ""} = Integer.parse(down_payment["purchase_id"] || 1)
            purchase = CattlePurchase.Repo.get(CattlePurchase.Purchase, purchase_id)
            CattlePurchase.Purchase.changeset(purchase, %{down_payments: down_payments_in_form})
          else
            %{
              purchase_changeset: purchase_changeset,
              purchase_param: purchase_param,
              purchase_details_in_form: purchase_details_in_form,
              selected_seller: selected_seller,
              commissions_in_form: commissions_in_form,
              selected_payee: selected_payee
            } = socket.assigns

            {:ok, purchase} =
              Purchases.create_or_update_purchase(purchase_changeset.data, purchase_param)

            purchase_details_to_save =
              purchase_details_in_form
              |> PurchaseDetails.remove_valid_key_add_purchase_id(purchase.id)
              |> Enum.map(fn purchase_detail ->
                PurchaseDetails.validate(%PurchaseDetail{}, purchase_detail)
              end)

            PurchaseDetails.create_or_update_multiple_purchase_details(
              purchase_details_to_save,
              false
            )

            PurchaseSellers.create_or_update_purchase_seller(%PurchaseSeller{}, %{
              purchase_id: purchase.id,
              seller_id: selected_seller.id
            })

            PurchasePayees.create_or_update_purchase_payee(%PurchasePayee{}, %{
              purchase_id: purchase.id,
              payee_id: selected_payee.id
            })

            first_commission = Enum.at(commissions_in_form, 0)

            if(first_commission.commission_payee_id != "") do
              commissions_to_save =
                commissions_in_form
                |> Commissions.remove_valid_key_add_purchase_id(purchase.id)
                |> Enum.map(fn commission -> Commissions.validate(%Commission{}, commission) end)

              Commissions.create_or_update_multiple_commissions(
                commissions_to_save,
                false
              )
            end

            down_payments_in_form
            |> remove_valid_key_add_purchase_id(purchase.id)
            |> Enum.map(fn down_payment -> DownPayments.validate(%DownPayment{}, down_payment) end)
          end

        result =
          case down_payment_edit_phase do
            true ->
              CattlePurchase.Repo.update(down_payments_to_save)

            false ->
              DownPayments.create_or_update_multiple_commissions(
                down_payments_to_save,
                down_payment_edit_phase
              )
          end

        case result do
          {:ok, _commission} ->
            send(socket.assigns.parent_pid, {:down_payments_created, true})

            {:noreply,
             push_patch(socket,
               to: Routes.live_path(socket, PurchaseLive)
             )}

          {:error, %Ecto.Changeset{} = changest} ->
            {:noreply,
             assign(socket,
               down_payment_changeset: changest,
               down_payments_in_form: down_payments_in_form
             )}
        end

        {:noreply, socket}
      end
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

  def handle_event("skip_step", _param, socket) do
    %{
      purchase_changeset: purchase_changeset,
      purchase_param: purchase_param,
      purchase_details_in_form: purchase_details_in_form,
      selected_seller: selected_seller,
      commissions_in_form: commissions_in_form,
      selected_payee: selected_payee
    } = socket.assigns

    send(
      socket.assigns.parent_pid,
      {:down_payments_skip,
       purchase_changeset: purchase_changeset,
       purchase_param: purchase_param,
       purchase_details_in_form: purchase_details_in_form,
       selected_seller: selected_seller,
       selected_payee: selected_payee,
       commissions_in_form: commissions_in_form}
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

  def handle_event("back_step", _, socket) do
    %{down_payments_in_form: down_payments_in_form} = socket.assigns

    send(
      socket.assigns.parent_pid,
      {:back_step_from_down_payment, down_payments_in_form: down_payments_in_form}
    )

    {:noreply, socket}
  end

  def handle_event("delete_down_payment", params, socket) do
    {index, ""} = Integer.parse(params["index"])
    %{down_payments_in_form: down_payments_in_form} = socket.assigns

    down_payments_in_form =
      cond do
        length(down_payments_in_form) > 1 ->
          List.delete_at(down_payments_in_form, index)

        true ->
          down_payments_in_form
      end

    socket = assign(socket, down_payments_in_form: down_payments_in_form)
    {:noreply, socket}
  end

  def handle_event("delete_down_payment_in_db", params, socket) do
    {index, ""} = Integer.parse(params["index"])
    %{down_payments_in_form: down_payments_in_form} = socket.assigns

    down_payment = Enum.at(down_payments_in_form, index)

    DownPayments.delete_down_payment(Repo.get(DownPayment, down_payment.id))

    down_payments_in_form =
      cond do
        length(down_payments_in_form) > 1 ->
          List.delete_at(down_payments_in_form, index)

        true ->
          []
      end

    send(
      socket.assigns.parent_pid,
      {:delete_down_payment_in_db, length(down_payments_in_form), socket.assigns.parent_id}
    )

    socket =
      assign(socket,
        down_payments_in_form: down_payments_in_form,
        down_payments_from_db: down_payments_in_form
      )

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
          description: down_payment_description,
          amount: down_payment_amount,
          date_paid: down_payment_date_paid,
          locked: down_payment_locked
        }

        valid = check_valid_down_payment(result)
        result = Map.put(result, :valid, valid)

        if Map.has_key?(c, :read_only) do
          Map.merge(
            %{
              description: c.description,
              amount: c.amount,
              date_paid: c.date_paid,
              locked: c.locked,
              read_only: c.read_only
            },
            result
          )
        else
          result
        end
      end)

    down_payments_in_form
  end

  defp check_valid_down_payment(down_payment) do
    if(
      down_payment.description != "" && down_payment.amount != "" &&
        down_payment.amount >= 1
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
