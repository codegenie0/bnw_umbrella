defmodule BnwDashboardWeb.CattlePurchase.Purchase.PurchaseSellerComponent do
  @moduledoc """
  ### Live view component for the add/update purchase modal.
  """
  use BnwDashboardWeb, :live_component
  alias CattlePurchase.{Purchases, Sellers, Seller, Repo}
  alias BnwDashboardWeb.CattlePurchase.Purchase.PurchaseLive

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"seller" => seller}, socket) do
    %{
      seller_changeset: seller_changeset,
      sellers_in_form: sellers_in_form,
      seller_edit_phase: seller_edit_phase,
      sellers_from_db: sellers_from_db
    } = socket.assigns

    %{"button" => button} = seller
    {purchase_id, ""} = Integer.parse(seller["purchase_id"] || 1)
    purchase = CattlePurchase.Repo.get(CattlePurchase.Purchase, purchase_id)

    seller_changeset = Sellers.validate(seller_changeset.data, seller)
    sellers_in_form = format_sellers(seller, sellers_in_form)

    if is_all_seller_valid(sellers_in_form) do
      sellers_to_save =
        if seller_edit_phase do
          CattlePurchase.Purchase.changeset(purchase, %{sellers: sellers_in_form})

          # |> remove_valid_key_add_purchase_id(purchase_id)
          # |> Enum.with_index()
          # |> Enum.map(fn {c, i} ->
          #   Sellers.update_validate(Enum.at(sellers_from_db, i), c)
          # end)
        else
          sellers_in_form
          |> remove_valid_key_add_purchase_id(purchase_id)
          |> Enum.map(fn seller -> Sellers.validate(%Seller{}, seller) end)
        end

      result =
        case seller_edit_phase do
          true ->
            CattlePurchase.Repo.update(sellers_to_save)

          false ->
            Sellers.create_or_update_multiple_commissions(
              sellers_to_save,
              seller_edit_phase
            )
        end

      case result do
        {:ok, _commission} ->
          send(socket.assigns.parent_pid, {:sellers_created, true})

          {:noreply,
           push_patch(socket,
             to: Routes.live_path(socket, PurchaseLive)
           )}

        {:error, %Ecto.Changeset{} = changest} ->
          {:noreply,
           assign(socket,
             seller_changeset: changest,
             sellers_in_form: sellers_in_form
           )}
      end

      {:noreply, socket}
    else
      {:noreply,
       assign(socket,
         seller_changeset: seller_changeset,
         sellers_in_form: sellers_in_form
       )}
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
    {:noreply, socket}
  end

  def handle_event("delete_seller", params, socket) do
    {index, ""} = Integer.parse(params["index"])
    %{sellers_in_form: sellers_in_form} = socket.assigns

    sellers_in_form =
      cond do
        length(sellers_in_form) > 1 ->
          List.delete_at(sellers_in_form, index)

        true ->
          sellers_in_form
      end

    socket = assign(socket, sellers_in_form: sellers_in_form)
    {:noreply, socket}
  end

  def handle_event("delete_seller_in_db", params, socket) do
    {index, ""} = Integer.parse(params["index"])
    %{sellers_in_form: sellers_in_form} = socket.assigns

    seller = Enum.at(sellers_in_form, index)

    Sellers.delete_seller(Repo.get(Seller, seller.id))

    sellers_in_form =
      cond do
        length(sellers_in_form) > 1 ->
          List.delete_at(sellers_in_form, index)

        true ->
          []
      end

    send(
      socket.assigns.parent_pid,
      {:delete_seller_in_db, length(sellers_in_form), socket.assigns.parent_id}
    )

    socket =
      assign(socket,
        sellers_in_form: sellers_in_form,
        sellers_from_db: sellers_in_form
      )

    {:noreply, socket}
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
