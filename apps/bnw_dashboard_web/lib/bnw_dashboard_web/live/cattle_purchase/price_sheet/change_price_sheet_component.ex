defmodule BnwDashboardWeb.CattlePurchase.PriceSheet.ChangePriceSheetComponent do
  @moduledoc """
  ### Live view component for the add/update destination groups modal.
  """
  use BnwDashboardWeb, :live_component
  alias CattlePurchase.PriceSheets
  alias BnwDashboardWeb.CattlePurchase.PriceSheet.PriceSheetLive

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"price_sheet" => price_sheet}, socket) do
    %{changeset: changeset} = socket.assigns

    price_sheet_details =
      if changeset.data.id == nil do
        Enum.reduce(PriceSheets.get_weight_categories_for_create(), [], fn wc, acc ->
          result =
            Enum.map(PriceSheets.get_active_sex_with_order_for_create(), fn sex ->
              [%{"weight_category_id" => wc, "sex_id" => sex}]
            end)

          acc ++ result
        end)
        |> List.flatten()
      end

    price_sheet =
      if price_sheet_details,
        do: Map.put(price_sheet, "price_sheet_details", price_sheet_details),
        else: price_sheet

    changeset = PriceSheets.validate(changeset.data, price_sheet)

    if changeset.valid? do
      case PriceSheets.create_or_update_price_sheet(changeset.data, price_sheet) do
        {:ok, _price_sheet} ->
          {:noreply, push_patch(socket, to: Routes.live_path(socket, PriceSheetLive))}

        {:error, %Ecto.Changeset{} = changest} ->
          {:noreply, assign(socket, changeset: changest)}
      end
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("validate", %{"price_sheet" => params}, socket) do
    %{changeset: changeset} = socket.assigns

    changeset =
      changeset.data
      |> PriceSheets.change_price_sheet(params)
      |> Map.put(:action, :update)

    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end
end
