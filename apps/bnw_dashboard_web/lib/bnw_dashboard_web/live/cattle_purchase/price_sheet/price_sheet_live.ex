defmodule BnwDashboardWeb.CattlePurchase.PriceSheet.PriceSheetLive do
  use BnwDashboardWeb, :live_view

  alias CattlePurchase.{
    Authorize,
    PriceSheets,
    PriceSheet
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
        price_sheets:
          PriceSheets.list_price_sheets()
          |> Enum.map(&Map.put(&1, :editable, false)),
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
  def handle_event("row-editable", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    price_sheets = socket.assigns.price_sheets
    price_sheet = Enum.find(price_sheets, fn item -> item.id == id end)
    editable_price_sheet_data = make_price_sheet_editable_data(price_sheet, socket)

    price_sheets =
      Enum.map(price_sheets, fn item ->
        if(item.id == id) do
          Map.put(item, :editable, true)
        else
          item
        end
      end)

    {:noreply,
     assign(socket,
       price_sheets: price_sheets,
       editable_price_sheet_data: editable_price_sheet_data
     )}
  end

  @impl true
  def handle_event("on_sex_edit", params, socket) do
    actual_value = if params["value"] == "", do: "0", else: params["value"]
    {weight, ""} = Integer.parse(params["weight"])
    {sex, ""} = Integer.parse(params["sex"])
    {value, ""} = Integer.parse(actual_value)

    editable_price_sheet_data = socket.assigns.editable_price_sheet_data

    price_sheet_details =
      Enum.map(editable_price_sheet_data.price_sheet_details, fn item ->
        if(item.weight_category_id == weight && item.sex_id == sex) do
          Map.put(item, :value, value)
        else
          item
        end
      end)

    editable_price_sheet_data =
      Map.put(editable_price_sheet_data, :price_sheet_details, price_sheet_details)

    IO.inspect(editable_price_sheet_data)

    {:noreply,
     assign(socket,
       editable_price_sheet_data: editable_price_sheet_data
     )}
  end

  @impl true
  def handle_event("cancel_editable_row", params, socket) do
    price_sheets = socket.assigns.price_sheets

    price_sheets =
      Enum.map(price_sheets, fn price_sheet ->
        Map.put(price_sheet, :editable, false)
      end)

    {:noreply, assign(socket, price_sheets: price_sheets, editable_price_sheet_data: nil)}
  end

  @impl true
  def handle_event("update_editable_row", params, socket) do
    price_sheets = socket.assigns.price_sheets
    {id, ""} = Integer.parse(params["id"])
    price_sheets = socket.assigns.price_sheets
    price_sheet = CattlePurchase.Repo.get(PriceSheet, id)

    editable_price_sheet_data = socket.assigns.editable_price_sheet_data |> Map.delete(:id)

    PriceSheets.create_or_update_price_sheet(price_sheet, editable_price_sheet_data)

    price_sheets =
      Enum.map(price_sheets, fn price_sheet ->
        Map.put(price_sheet, :editable, false)
      end)

    {:noreply, assign(socket, price_sheets: price_sheets, editable_price_sheet_data: nil)}
  end

  @impl true
  def handle_event("validate", params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:price_sheets, :created_or_updated], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)

    {:noreply,
     assign(socket,
       price_sheets: PriceSheets.list_price_sheets() |> Enum.map(&Map.put(&1, :editable, false))
     )}
  end

  defp make_price_sheet_editable_data(price_sheet, socket) do
    data = %{id: price_sheet.id, price_date: price_sheet.price_date, price_sheet_details: []}
    weight_categories = socket.assigns.weight_categories

    result =
      Enum.reduce(weight_categories, [], fn item, acc ->
        sexes = price_sheet.price_sheet_details[item.start_weight]

        result =
          Enum.map(sexes, fn sex ->
            %{weight_category_id: item.id, sex_id: sex.sex_id, value: sex.value}
          end)

        acc = acc ++ result
      end)

    IO.inspect(result)
    Map.put(data, :price_sheet_details, result)
  end
end
