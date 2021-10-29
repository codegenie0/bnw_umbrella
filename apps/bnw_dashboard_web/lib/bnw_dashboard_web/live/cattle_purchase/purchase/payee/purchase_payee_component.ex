defmodule BnwDashboardWeb.CattlePurchase.Purchase.PurchasePayeeComponent do
  @moduledoc """
  ### Live view component for the add/update purchase modal.
  """
  use BnwDashboardWeb, :live_component

  alias CattlePurchase.{
    Purchases,
    Payees,
    PurchasePayees,
    PurchasePayee,
    Payee,
    Repo,
    PurchaseDetails,
    PurchaseDetail,
    PurchaseSeller,
    PurchaseSellers
  }

  alias BnwDashboardWeb.CattlePurchase.Purchase.PurchaseLive

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", params, socket) do
    %{"button" => button} = params

    %{
      payee_edit_phase: payee_edit_phase,
      selected_payee: selected_payee,
      parent_id: purchase_id
    } = socket.assigns

    # {purchase_id, ""} = Integer.parse(params["purchase_id"] || 1)
    # purchase_id = 1

    if(selected_payee) do
      if button == "Next" do
        send(
          socket.assigns.parent_pid,
          {:next_step_from_payee_, selected_payee: selected_payee}
        )

        {:noreply, push_patch(socket, to: Routes.live_path(socket, PurchaseLive))}
      else
        if(payee_edit_phase) do
          payee_to_delete = PurchasePayees.get_payee_from_purchase_id(purchase_id)
          PurchasePayees.delete_purchase_payee(payee_to_delete)
        end

        purchase_id =
          if payee_edit_phase do
            purchase_id
          else
            %{
              purchase_changeset: purchase_changeset,
              purchase_param: purchase_param,
              purchase_details_in_form: purchase_details_in_form,
              selected_seller: selected_seller
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

            purchase.id
          end

        case PurchasePayees.create_or_update_purchase_payee(%PurchasePayee{}, %{
               purchase_id: purchase_id,
               payee_id: selected_payee.id
             }) do
          {:ok, _} ->
            send(
              socket.assigns.parent_pid,
              {:purchase_payee_created, button: button, purchase_id: purchase_id}
            )

            {:noreply,
             push_patch(socket,
               to: Routes.live_path(socket, PurchaseLive)
             )}

          {:error, %Ecto.Changeset{} = changest} ->
            {:noreply, assign(socket, payee_changeset: changest, payee_error: false)}
        end
      end
    else
      {:noreply, assign(socket, payee_error: true)}
    end
  end

  def handle_event("validate", %{"payee" => params}, socket) do
    %{payees_in_form: payees_in_form} = socket.assigns

    socket =
      assign(socket,
        payees_in_form: format_payees(params, payees_in_form)
      )

    {:noreply, socket}
  end

  def handle_event("back_step", _, socket) do
    %{payees_in_form: payees_in_form, selected_payee: selected_payee} = socket.assigns

    send(
      socket.assigns.parent_pid,
      {:back_step_from_payee, payees_in_form: payees_in_form, selected_payee: selected_payee}
    )

    {:noreply, socket}
  end

  def handle_event("on_row_selected", params, socket) do
    id = params["id"]
    payees = socket.assigns.payees
    payee = Enum.find(payees, fn item -> item.id == params["id"] end)
    {:noreply, assign(socket, selected_payee: payee)}
  end

  def handle_event("clear_selected_payee", params, socket) do
    {:noreply, assign(socket, selected_payee: nil)}
  end

  def handle_event("on_input_search", params, socket) do
    %{"value" => value} = params
    payees = Payees.search_query(value)
    {:noreply, assign(socket, search_query: value, payees: payees)}
  end

  @impl true
  def handle_event("load_more", _params, socket) do

    socket = assign_total_pages(socket)
    socket = load_more(socket)
    {:noreply, socket}
  end

  defp assign_total_pages(socket) do
    %{
      per_page: per_page,
      search_query: search_query
    } = socket.assigns

    total_pages = Payees.get_payees_data_total_pages(per_page, search_query)
    assign(socket, :total_pages, total_pages)
  end

  defp load_more(socket) do
    %{
      page: page,
      total_pages: total_pages
    } = socket.assigns

    cond do
      page < total_pages ->
        socket
        |> assign(:page, page + 1)
        |> assign(:update_action, "append")
        |> assign_payees()

      true ->
        socket
    end
  end

  defp assign_payees(socket) do
    %{
      page: page,
      per_page: per_page,
      search_query: search_query,
      update_action: update_action
    } = socket.assigns

    new_payees = Payees.list_payees(page, per_page, search_query)

    payees =
      cond do
        update_action == "append" ->
          Map.get(socket.assigns, :payees, []) ++ new_payees

        true ->
          new_payees
      end

    assign(socket, :payees, payees)
  end

  defp format_payees(payees_params, payees_in_form) do
    payees_in_form =
      payees_in_form
      |> Enum.with_index()
      |> Enum.map(fn {c, i} ->
        key_description = Integer.to_string(i) <> "_description"
        key_amount = Integer.to_string(i) <> "_amount"
        key_date_paid = Integer.to_string(i) <> "_date_paid"
        key_locked = Integer.to_string(i) <> "_locked"

        payee_description =
          if payees_params[key_description] != "",
            do: payees_params[key_description],
            else: ""

        payee_amount =
          if payees_params[key_amount] != "",
            do: payees_params[key_amount],
            else: ""

        payee_date_paid =
          if payees_params[key_date_paid] != "",
            do: payees_params[key_date_paid],
            else: ""

        payee_locked =
          if payees_params[key_locked] != "",
            do: payees_params[key_locked],
            else: ""

        result = %{
          description: payee_description,
          amount: payee_amount,
          date_paid: payee_date_paid,
          locked: payee_locked
        }

        valid = check_valid_payee(result)
        result = Map.put(result, :valid, valid)
      end)

    payees_in_form
  end

  defp check_valid_payee(payee) do
    if(
      payee.description != "" && payee.amount != "" &&
        payee.amount >= 1 &&
        payee.date_paid != ""
    ) do
      true
    else
      false
    end
  end

  defp is_all_payee_valid(payees) do
    payees = Enum.filter(payees, fn item -> !item.valid end)
    if length(payees) >= 1, do: false, else: true
  end

  defp remove_valid_key_add_purchase_id(payees, purchase_id) do
    Enum.map(payees, fn item ->
      item
      |> Map.delete(:valid)
      |> Map.put(:purchase_id, purchase_id)
    end)
  end
end
