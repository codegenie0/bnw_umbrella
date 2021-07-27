defmodule BnwDashboardWeb.CattlePurchase.Purchase.PurchaseLive do
  use BnwDashboardWeb, :live_view

  alias CattlePurchase.{
    Authorize,
    Purchases,
    Purchase,
    PurchaseTypes,
    PurchaseTypeFilters,
    Repo
  }

  #  alias BnwDashboardWeb.CattlePurchase.Purchases.PurchaseSearchComponent

  defp authenticate(socket) do
    current_user = Map.get(socket.assigns, :current_user)

    cond do
      current_user && Authorize.authorize(current_user, "purchases") ->
        true

      true ->
        false
    end
  end

  @impl true
  def mount(_, session, socket) do
    active_purchase_types =
      PurchaseTypes.get_active_purchase_types()
      |> Enum.map(fn item -> %{id: item.id, name: item.name, checked: false} end)

    purchase_type_filters =
      PurchaseTypeFilters.list_purchase_type_filters()
      |> Enum.map(fn item -> %{id: item.id, name: item.name, checked: false} end)

    toggle_complete = %{name: "toggle completed", checked: false}

    search_columns = [
      purchase_date: :purchase_date,
      seller: :seller,
      purchase_location: :origin,
      purchase_order: :purchase_order,
      head_count: :head_count,
      sex: :sex,
      weight: :weight,
      price: :price,
      buyer: :buyer,
      destination: :destination,
      ship_date: :estimated_ship_date,
      kill_date: :projected_out_date
    ]

    sort_columns = [
      %{name: "purchase_date", title: "Purchase Date", sort_by: nil, is_sort: true},
      %{name: "seller", title: "Seller", sort_by: nil, is_sort: true},
      %{name: "purchase_location", title: "Purchase Location", sort_by: nil, is_sort: true},
      %{name: "purchase_order", title: "Purchase Order", sort_by: nil, is_sort: true},
      %{name: "head_count", title: "Head Count", sort_by: nil, is_sort: true},
      %{name: "sex", title: "Sex", sort_by: nil, is_sort: false},
      %{name: "weight", title: "Weight", sort_by: nil, is_sort: true},
      %{name: "price", title: "Price", sort_by: nil, is_sort: true},
      %{name: "price_and_delivery", title: "Price and Delivery", sort_by: nil, is_sort: true},
      %{name: "delivered", title: "Delivered", sort_by: nil, is_sort: true},
      %{name: "buyer", title: "Buyer", sort_by: nil, is_sort: false},
      %{name: "destination", title: "Destination", sort_by: nil, is_sort: false},
      %{name: "ship_date", title: "Ship Date", sort_by: nil, is_sort: true},
      %{name: "firm", title: "Firm", sort_by: nil, is_sort: true},
      %{name: "kill_date", title: "Kill Date", sort_by: nil, is_sort: true},
      %{name: "projected_break_even", title: "Projected Break Even", sort_by: nil, is_sort: true},
      %{name: "complete", title: "Complete", sort_by: nil, is_sort: true}
    ]

    purchases = Purchases.list_purchases()

    socket =
      assign_defaults(session, socket)
      |> assign(
        page_title: "Purchase",
        app: "Cattle Purchase",
        purchases: purchases,
        active_purchase_types: active_purchase_types,
        purchase_type_filters: purchase_type_filters,
        toggle_complete: toggle_complete,
        search_columns: search_columns,
        sort_columns: sort_columns,
        purchase_search: %{
          column_name: "Select column for search",
          search_value: "",
          start_date: "",
          end_date: ""
        }
      )

    if connected?(socket) do
      Purchases.subscribe()
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

  def handle_event(
        "validate",
        %{"purchase_search" => purchase_search},
        socket
      ) do
    start_date =
      if !(String.strip(purchase_search["start_date"]) == "") &&
           purchase_search["start_date"] !=
             socket.assigns.purchase_search.start_date do
        purchase_search["start_date"]
        # assign(socket, start_date: purchase_search["start_date"])
      end

    end_date =
      if !(String.strip(purchase_search["end_date"]) == "") &&
           purchase_search["end_date"] !=
             socket.assigns.purchase_search.end_date do
        purchase_search["end_date"]
        # assign(socket, end_date: purchase_search["end_date"])
      end

    search_value =
      if !(String.strip(purchase_search["search_value"]) == "") &&
           purchase_search["search_value"] !=
             socket.assigns.purchase_search.search_value do
        purchase_search["search_value"]
        # assign(socket, search_value: purchase_search["search_value"])
      end

    column_name =
      if purchase_search["column_name"] != "" do
        purchase_search["column_name"]
      else
        "Select column for search"
        # assign(socket, column_name: purchase_search["column_name"])
      end

    socket =
      assign(socket,
        purchase_search: %{
          start_date: start_date || socket.assigns.purchase_search.start_date,
          end_date: end_date || socket.assigns.purchase_search.end_date,
          search_value: search_value || socket.assigns.purchase_search.search_value,
          column_name: column_name || socket.assigns.purchase_search.column_name
        }
      )

    {:noreply, socket}
  end

  # def handle_event("search", _params, socket) do
  #   {:noreply, socket}
  # end

  def handle_event(
        "handle_toggle_purchase_type",
        %{"id" => _} = params,
        socket
      ) do
    {id, ""} = Integer.parse(params["id"])

    active_purchase_types =
      socket.assigns.active_purchase_types
      |> Enum.map(fn item ->
        if(item.id == id) do
          Map.put(item, :checked, !item.checked)
        else
          item
        end
      end)

    {:noreply, assign(socket, active_purchase_types: active_purchase_types)}
  end

  def handle_event(
        "handle_toggle_purchase_type_filter",
        %{"id" => _} = params,
        socket
      ) do
    {id, ""} = Integer.parse(params["id"])

    purchase_type_filters =
      socket.assigns.purchase_type_filters
      |> Enum.map(fn item ->
        if(item.id == id) do
          Map.put(item, :checked, !item.checked)
        else
          item
        end
      end)

    {:noreply, assign(socket, purchase_type_filters: purchase_type_filters)}
  end

  def handle_event(
        "handle_toggle_completed",
        params,
        socket
      ) do
    toggle_complete =
      Map.put(socket.assigns.toggle_complete, :checked, !socket.assigns.toggle_complete.checked)

    {:noreply, assign(socket, toggle_complete: toggle_complete)}
  end

  def handle_event(
        "toggle-purchase-sort",
        %{"column" => column},
        socket
      ) do
    sort_columns = socket.assigns.sort_columns

    sort_columns =
      Enum.map(sort_columns, fn sort_column ->
        if(sort_column.name == column) do
          sort_by = if sort_column.sort_by == nil, do: true, else: !sort_column.sort_by
          Map.put(sort_column, :sort_by, sort_by)
        else
          sort_column
        end
      end)

    selected_column = Enum.find(sort_columns, fn sort_column -> sort_column.name == column end)
    sortOrder = if selected_column.sort_by, do: "asc", else: "desc"

    purchases = Purchases.sort_by(Purchase, sortOrder, selected_column.name) |> Repo.all()

    {:noreply, assign(socket, purchases: purchases, sort_columns: sort_columns)}
  end
end
