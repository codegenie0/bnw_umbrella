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
        weight_categories: PriceSheets.get_weight_categories(),
        sexes: PriceSheets.get_active_sex_with_order(),
        modal: nil,
        page: 1,
        per_page: 7,
        total_pages: 1,
        search: "",
        update_action: "replace"
      )

    socket = fetch_price_sheet(socket)

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

  defp fetch_price_sheet(socket) do
    %{page: page, per_page: per_page} = socket.assigns

    price_sheets =
      PriceSheets.list_price_sheets_by_page(page, per_page)
      |> Enum.map(&Map.put(&1, :editable, false))

    assign(socket, price_sheets: price_sheets)
  end

  @impl true
  def handle_event("load_more", _params, socket) do
    %{
      current_user: _current_user
    } = socket.assigns

    socket = assign_total_pages(socket)
    socket = load_more(socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("on_comment_edit", params, socket) do
    actual_value = if params["value"] == "", do: "0", else: params["value"]

    editable_price_sheet_data =
      socket.assigns.editable_price_sheet_data |> Map.put(:comment, actual_value)

    socket = assign(socket, editable_price_sheet_data: editable_price_sheet_data)
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
  def handle_event("delete", params, socket) do
    {id, ""} = Integer.parse(params["id"])

    Enum.find(socket.assigns.price_sheets, fn pg -> pg.id == id end)
    |> PriceSheets.delete_price_sheet()

    {:noreply, socket}
  end

  @impl true
  def handle_event("clear_filters", _, socket) do
    {:noreply,
     assign(socket,
       price_sheet_search: %{
         start_date: "",
         end_date: ""
       },
       price_sheets:
         PriceSheets.list_price_sheets()
         |> Enum.map(&Map.put(&1, :editable, false))
     )}
  end

  def handle_event(
        "validate",
        %{"price_sheet_search" => price_sheet_search},
        socket
      ) do
    start_date =
      if !(String.trim(price_sheet_search["start_date"]) == "") &&
           price_sheet_search["start_date"] !=
             socket.assigns.price_sheet_search.start_date do
        price_sheet_search["start_date"]
      end

    end_date =
      if !(String.trim(price_sheet_search["end_date"]) == "") &&
           price_sheet_search["end_date"] !=
             socket.assigns.price_sheet_search.end_date do
        price_sheet_search["end_date"]
      end

    socket =
      assign(socket,
        price_sheet_search: %{
          start_date: start_date || socket.assigns.price_sheet_search.start_date,
          end_date: end_date || socket.assigns.price_sheet_search.end_date
        }
      )

    {:noreply, socket}
  end

  def handle_event("search", _params, socket) do
    price_search_filters = socket.assigns.price_sheet_search

    start_date =
      if String.trim(price_search_filters.start_date) == "",
        do: nil,
        else: price_search_filters.start_date

    end_date =
      if String.trim(price_search_filters.end_date) == "",
        do: nil,
        else: price_search_filters.end_date

    price_sheets =
      CattlePurchase.PriceSheet
      |> PriceSheets.price_date_range(start_date, end_date)
      |> Enum.map(&Map.put(&1, :editable, false))

    {:noreply, assign(socket, price_sheets: price_sheets)}
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
    {value, ""} = Float.parse(actual_value)

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

    {:noreply,
     assign(socket,
       editable_price_sheet_data: editable_price_sheet_data
     )}
  end

  @impl true
  def handle_event("cancel_editable_row", _params, socket) do
    price_sheets = socket.assigns.price_sheets

    price_sheets =
      Enum.map(price_sheets, fn price_sheet ->
        Map.put(price_sheet, :editable, false)
      end)

    {:noreply, assign(socket, price_sheets: price_sheets, editable_price_sheet_data: nil)}
  end

  @impl true
  def handle_event("update_editable_row", params, socket) do
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
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
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
        |> assign_price_sheets()

      true ->
        socket
    end
  end

  defp assign_price_sheets(socket) do
    %{
      page: page,
      per_page: per_page,
      search: _search,
      update_action: _update_action
    } = socket.assigns

    price_sheets =
      Map.get(socket.assigns, :price_sheets, []) ++
        PriceSheets.list_price_sheets_by_page(page, per_page)

    price_sheets = Enum.map(price_sheets, &Map.put(&1, :editable, false))

    assign(socket, :price_sheets, price_sheets)
  end

  defp assign_total_pages(socket) do
    %{
      per_page: per_page,
      search: search
    } = socket.assigns

    total_pages = PriceSheets.get_price_sheet_data_total_pages(per_page, search)
    assign(socket, :total_pages, total_pages)
  end


  @impl true
  def handle_info({[:price_sheets, :created_or_updated], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)

    {:noreply,
     assign(socket,
       price_sheets: PriceSheets.list_price_sheets() |> Enum.map(&Map.put(&1, :editable, false))
     )}
  end


  @impl true
  def handle_info({[:price_sheets, :deleted], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)

    {:noreply,
     assign(socket,
       price_sheets: PriceSheets.list_price_sheets() |> Enum.map(&Map.put(&1, :editable, false))
     )}
  end

  defp make_price_sheet_editable_data(price_sheet, socket) do
    data = %{
      id: price_sheet.id,
      comment: price_sheet.comment,
      price_date: price_sheet.price_date,
      price_sheet_details: []
    }

    weight_categories = socket.assigns.weight_categories

    result =
      Enum.reduce(weight_categories, [], fn item, acc ->
        sexes = price_sheet.price_sheet_details[item.start_weight]

        result =
          Enum.map(sexes, fn sex ->
            %{weight_category_id: item.id, sex_id: sex.sex_id, value: sex.value}
          end)

          acc ++ result
      end)

    Map.put(data, :price_sheet_details, result)
  end
end
