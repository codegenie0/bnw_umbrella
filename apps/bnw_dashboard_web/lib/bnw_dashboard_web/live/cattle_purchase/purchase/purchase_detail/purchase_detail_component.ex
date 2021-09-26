defmodule BnwDashboardWeb.CattlePurchase.Purchase.PurchaseDetailComponent do
  @moduledoc """
  ### Live view component for the add/update purchase modal.
  """
  use BnwDashboardWeb, :live_component
  alias CattlePurchase.{PurchaseDetails, PurchaseDetail, Repo, PurchaseDetails}
  alias BnwDashboardWeb.CattlePurchase.Purchase.PurchaseLive

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"purchase_detail" => purchase_detail}, socket) do
    %{
      purchase_detail_changeset: purchase_detail_changeset,
      purchase_details_in_form: purchase_details_in_form,
      purchase_detail_edit_phase: purchase_detail_edit_phase,
      purchase_details_from_db: purchase_details_from_db
    } = socket.assigns

    %{"button" => button} = purchase_detail
    {purchase_id, ""} = Integer.parse(purchase_detail["purchase_id"] || 1)

    purchase_detail_changeset =
      PurchaseDetails.validate(purchase_detail_changeset.data, purchase_detail)

    purchase_details_in_form = format_purchase_details(purchase_detail, purchase_details_in_form)
    purchase = CattlePurchase.Repo.get(CattlePurchase.Purchase, purchase_id)

    if is_all_purchase_details_valid(purchase_details_in_form) do
      purchase_details_to_save =
        if purchase_detail_edit_phase do
          CattlePurchase.Purchase.changeset(purchase, %{
            purchase_details: purchase_details_in_form
          })
        else
          purchase_details_in_form
          |> remove_valid_key_add_purchase_id(purchase_id)
          |> Enum.map(fn purchase_detail ->
            PurchaseDetails.validate(%PurchaseDetail{}, purchase_detail)
          end)
        end


      result =
        case purchase_detail_edit_phase do
          true ->
            CattlePurchase.Repo.update(purchase_details_to_save)

          false ->
            PurchaseDetails.create_or_update_multiple_purchase_details(
              purchase_details_to_save,
              purchase_detail_edit_phase
            )
        end

      case result do
        {:ok, _purchase_detail} ->
          send(
            socket.assigns.parent_pid,
            {:purchase_detail_created, button: button, purchase_id: purchase.id}
          )

          {:noreply,
           push_patch(socket,
             to: Routes.live_path(socket, PurchaseLive)
           )}

        {:error, %Ecto.Changeset{} = changest} ->
          {:noreply,
           assign(socket,
             purchase_detail_changeset: changest,
             purchase_details_in_form: purchase_details_in_form
           )}
      end

      {:noreply, socket}
    else
      {:noreply,
       assign(socket,
         purchase_detail_changeset: purchase_detail_changeset,
         purchase_details_in_form: purchase_details_in_form
       )}
    end
  end

  def handle_event("validate", %{"purchase_detail" => params}, socket) do
    %{purchase_detail_changeset: purchase_detail_changeset} = socket.assigns
    %{purchase_details_in_form: purchase_details_in_form} = socket.assigns

    purchase_detail_changeset =
      purchase_detail_changeset.data
      |> PurchaseDetails.change_purchase_detail(params)
      |> Map.put(:action, :update)

    socket =
      assign(socket,
        purchase_detail_changeset: purchase_detail_changeset,
        purchase_details_in_form: format_purchase_details(params, purchase_details_in_form)
      )

    {:noreply, socket}
  end

  def handle_event("add_purchase_detail", _, socket) do
    %{purchase_details_in_form: purchase_details_in_form} = socket.assigns

    purchase_details_in_form =
      purchase_details_in_form ++
        [
          %{
            sex_id: "",
            head_count: 0,
            average_weight: 0,
            price: 0,
            projected_break_even: 0,
            projected_out_date: "",
            purchase_basis: "",
            valid: true
          }
        ]

    socket = assign(socket, purchase_details_in_form: purchase_details_in_form)
    {:noreply, socket}
  end

  def handle_event("delete_purchase_detail", params, socket) do
    {index, ""} = Integer.parse(params["index"])
    %{purchase_details_in_form: purchase_details_in_form} = socket.assigns

    purchase_details_in_form =
      cond do
        length(purchase_details_in_form) > 1 ->
          List.delete_at(purchase_details_in_form, index)

        true ->
          purchase_details_in_form
      end

    socket = assign(socket, purchase_details_in_form: purchase_details_in_form)
    {:noreply, socket}
  end

  def handle_event("delete_purchase_detail_in_db", params, socket) do
    {index, ""} = Integer.parse(params["index"])
    %{purchase_details_in_form: purchase_details_in_form} = socket.assigns

    purchase_detail = Enum.at(purchase_details_in_form, index)

    PurchaseDetails.delete_purchase_detail(Repo.get(PurchaseDetail, purchase_detail.id))

    purchase_details_in_form =
      cond do
        length(purchase_details_in_form) > 1 ->
          List.delete_at(purchase_details_in_form, index)

        true ->
          []
      end

    send(
      socket.assigns.parent_pid,
      {:delete_purchase_detail_in_db, length(purchase_details_in_form), socket.assigns.parent_id}
    )

    socket =
      assign(socket,
        purchase_details_in_form: purchase_details_in_form,
        purchase_details_from_db: purchase_details_in_form
      )

    {:noreply, socket}
  end

  defp format_purchase_details(purchase_details_params, purchase_details_in_form) do

    purchase_details_in_form =
      purchase_details_in_form
      |> Enum.with_index()
      |> Enum.map(fn {_c, i} ->
        key_sex_id = Integer.to_string(i) <> "_sex_id"
        key_average_weight = Integer.to_string(i) <> "_average_weight"
        key_price = Integer.to_string(i) <> "_price"
        key_projected_break_even = Integer.to_string(i) <> "_projected_break_even"
        key_projected_out_date = Integer.to_string(i) <> "_projected_out_date"
        key_head_count = Integer.to_string(i) <> "_head_count"
        key_purchase_basis = Integer.to_string(i) <> "_purchase_basis"

        purchase_detail_sex_id =
          if purchase_details_params[key_sex_id] != "",
            do: elem(Integer.parse(purchase_details_params[key_sex_id]), 0),
            else: ""

        purchase_detail_average_weight =
          if purchase_details_params[key_average_weight] != "",
            do: elem(Integer.parse(purchase_details_params[key_average_weight]), 0),
            else: ""

        purchase_detail_price =
          if purchase_details_params[key_price] != "",
            do: elem(Float.parse(purchase_details_params[key_price]), 0),
            else: ""

        purchase_detail_projected_break_even =
          if purchase_details_params[key_projected_break_even] != "",
            do: elem(Float.parse(purchase_details_params[key_projected_break_even]), 0),
            else: ""

        purchase_detail_projected_out_date =
          if purchase_details_params[key_projected_out_date] != "",
            do: purchase_details_params[key_projected_out_date],
            else: ""

        purchase_detail_head_count =
          if purchase_details_params[key_head_count] != "",
            do: elem(Integer.parse(purchase_details_params[key_head_count]), 0),
            else: ""

        purchase_detail_purchase_basis =
          if purchase_details_params[key_purchase_basis] != "",
            do: elem(Float.parse(purchase_details_params[key_purchase_basis]), 0),
            else: ""

        %{
          sex_id: purchase_detail_sex_id,
          average_weight: purchase_detail_average_weight,
          price: purchase_detail_price,
          projected_break_even: purchase_detail_projected_break_even,
          projected_out_date: purchase_detail_projected_out_date,
          head_count: purchase_detail_head_count,
          purchase_basis: purchase_detail_purchase_basis,
          valid:
            check_valid_purchase_detail(%{
              purchase_detail_sex_id: purchase_detail_sex_id,
              purchase_detail_average_weight: purchase_detail_average_weight,
              purchase_detail_price: purchase_detail_price,
              purchase_detail_projected_break_even: purchase_detail_projected_break_even,
              purchase_detail_projected_out_date: purchase_detail_projected_out_date,
              purchase_detail_head_count: purchase_detail_head_count,
              purchase_detail_purchase_basis: purchase_detail_purchase_basis
            })
        }
      end)

    purchase_details_in_form
  end

  defp check_valid_purchase_detail(purchase_detail) do
    if(
      purchase_detail.purchase_detail_sex_id != "" &&
        purchase_detail.purchase_detail_average_weight != "" &&
        purchase_detail.purchase_detail_price != "" &&
        purchase_detail.purchase_detail_projected_break_even != "" &&
        purchase_detail.purchase_detail_projected_out_date != "" &&
        purchase_detail.purchase_detail_head_count != "" &&
        purchase_detail.purchase_detail_purchase_basis != ""
    ) do
      true
    else
      false
    end
  end

  defp is_all_purchase_details_valid(purchase_details) do
    purchase_details = Enum.filter(purchase_details, fn item -> !item.valid end)
    if length(purchase_details) >= 1, do: false, else: true
  end

  defp remove_valid_key_add_purchase_id(purchase_details, purchase_id) do
    Enum.map(purchase_details, fn item ->
      item
      |> Map.delete(:valid)
      |> Map.put(:purchase_id, purchase_id)
    end)
  end
end
