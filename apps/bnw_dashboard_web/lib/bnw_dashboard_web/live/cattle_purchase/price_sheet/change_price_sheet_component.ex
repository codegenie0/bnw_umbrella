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
