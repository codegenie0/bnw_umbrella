defmodule BnwDashboardWeb.CattlePurchase.PriceSheet.PriceSheetLive do
  use BnwDashboardWeb, :live_view

  alias CattlePurchase.{
    Authorize,
    PriceSheets
  }

  alias BnwDashboardWeb.CattlePurchase.PriceSheet.ChangePriceSheetComponent

  defp authenticate(socket) do
    current_user = Map.get(socket.assigns, :current_user)

    cond do
      current_user && Authorize.authorize(current_user, "price_sheets") ->
        true

      true ->
        false
    end
  end

  @impl true
  def mount(_, session, socket) do
    socket =
      assign_defaults(session, socket)
      |> assign(
        page_title: "Price Sheets",
        app: "Cattle Purchase",
        price_sheet_search: %{
          start_date: "",
          end_date: ""
        },
        price_sheets: PriceSheets.list_price_sheets,
        weight_categories: PriceSheets.get_weight_categories(),
        sexes: PriceSheets.get_active_sex_with_order(),
        modal: nil
      )

    if connected?(socket) do
      PriceSheets.subscribe()
    end

    case authenticate(socket) do
      true -> {:ok, socket}
      false -> {:ok, redirect(socket, to: "/")}
    end
  end

  @impl true
  def handle_params(_, _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("new", _, socket) do
    changeset = PriceSheets.new_price_sheet()
    socket = assign(socket, changeset: changeset, modal: :change_price_sheet)

    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:price_sheets, :created_or_updated], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
    {:noreply, assign(socket, price_sheets: PriceSheets.list_price_sheets() )}
  end
end
