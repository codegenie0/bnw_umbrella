defmodule BnwDashboardWeb.CattlePurchase.Purchase.PurchaseSellerComponent do
  @moduledoc """
  ### Live view component for the add/update purchase modal.
  """
  use BnwDashboardWeb, :live_component
  alias CattlePurchase.{Purchases, Sellers, PurchaseSellers, PurchaseSeller, Seller, Repo}
  alias BnwDashboardWeb.CattlePurchase.Purchase.PurchaseLive

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", params, socket) do
    %{"button" => button} = params

    %{
      seller_edit_phase: seller_edit_phase,
      selected_seller: selected_seller,
      parent_id: purchase_id
    } = socket.assigns

    # {purchase_id, ""} = Integer.parse(params["purchase_id"] || 1)
    # purchase_id = 1

    if(selected_seller) do
      if(seller_edit_phase) do
        seller_to_delete = PurchaseSellers.get_seller_from_purchase_id(purchase_id)
        PurchaseSellers.delete_purchase_seller(seller_to_delete)
      end

      case PurchaseSellers.create_or_update_purchase_seller(%PurchaseSeller{}, %{
             purchase_id: purchase_id,
             seller_id: selected_seller.id
           }) do
        {:ok, _} ->
          send(
            socket.assigns.parent_pid,
            {:purchase_seller_created, button: button, purchase_id: purchase_id}
          )

          {:noreply,
           push_patch(socket,
             to: Routes.live_path(socket, PurchaseLive)
           )}

        {:error, %Ecto.Changeset{} = changest} ->
          {:noreply, assign(socket, seller_changeset: changest, seller_error: false)}
      end
    else
      {:noreply, assign(socket, seller_error: true)}
    end
  end

  def handle_event("validate", %{"seller" => params}, socket) do
    %{sellers_in_form: sellers_in_form} = socket.assigns

    socket =
      assign(socket,
        sellers_in_form: format_sellers(params, sellers_in_form)
      )

    {:noreply, socket}
  end

  def handle_event("on_row_selected", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    seller = Enum.find(Sellers.get_active_sellers(), fn item -> item.id == id end)

    {:noreply, assign(socket, selected_seller: seller)}
  end

  def handle_event("clear_selected_seller", params, socket) do
    {:noreply, assign(socket, selected_seller: nil)}
  end

  def handle_event("on_input_search", params, socket) do
    %{"value" => value} = params
    sellers = Sellers.search_query(value)
    {:noreply, assign(socket, search_query: value, sellers: sellers)}
  end

  defp format_sellers(sellers_params, sellers_in_form) do
    sellers_in_form =
      sellers_in_form
      |> Enum.with_index()
      |> Enum.map(fn {c, i} ->
        key_description = Integer.to_string(i) <> "_description"
        key_amount = Integer.to_string(i) <> "_amount"
        key_date_paid = Integer.to_string(i) <> "_date_paid"
        key_locked = Integer.to_string(i) <> "_locked"

        seller_description =
          if sellers_params[key_description] != "",
            do: sellers_params[key_description],
            else: ""

        seller_amount =
          if sellers_params[key_amount] != "",
            do: sellers_params[key_amount],
            else: ""

        seller_date_paid =
          if sellers_params[key_date_paid] != "",
            do: sellers_params[key_date_paid],
            else: ""

        seller_locked =
          if sellers_params[key_locked] != "",
            do: sellers_params[key_locked],
            else: ""

        result = %{
          description: seller_description,
          amount: seller_amount,
          date_paid: seller_date_paid,
          locked: seller_locked
        }

        valid = check_valid_seller(result)
        result = Map.put(result, :valid, valid)
      end)

    sellers_in_form
  end

  defp check_valid_seller(seller) do
    if(
      seller.description != "" && seller.amount != "" &&
        seller.amount >= 1 &&
        seller.date_paid != ""
    ) do
      true
    else
      false
    end
  end

  defp is_all_seller_valid(sellers) do
    sellers = Enum.filter(sellers, fn item -> !item.valid end)
    if length(sellers) >= 1, do: false, else: true
  end

  defp remove_valid_key_add_purchase_id(sellers, purchase_id) do
    Enum.map(sellers, fn item ->
      item
      |> Map.delete(:valid)
      |> Map.put(:purchase_id, purchase_id)
    end)
  end
end
