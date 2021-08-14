defmodule BnwDashboardWeb.CattlePurchase.Purchase.PurchaseLive do
  use BnwDashboardWeb, :live_view

  alias CattlePurchase.{
    Authorize,
    Purchases,
    Purchase,
    PurchaseTypes,
    PurchaseGroups,
    PurchaseFlags,
    PurchaseTypeFilters,
    DestinationGroups,
    Sexes,
    Repo
  }

  alias BnwDashboardWeb.CattlePurchase.Purchase.ChangePurchaseComponent
  alias BnwDashboardWeb.CattlePurchase.Purchase.CompletePurchaseComponent
  alias BnwDashboardWeb.CattlePurchase.PurchaseShipment.PurchaseShipmentLive

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
      %{name: "origin", title: "Purchase Location", sort_by: nil, is_sort: true},
      %{name: "purchase_order", title: "Purchase Order", sort_by: nil, is_sort: true},
      %{name: "head_count", title: "Head Count", sort_by: nil, is_sort: true},
      %{name: "sex", title: "Sex", sort_by: nil, is_sort: false},
      %{name: "received", title: "Received", sort_by: nil, is_sort: false},
      %{name: "weight", title: "Weight", sort_by: nil, is_sort: true},
      %{name: "price", title: "Price", sort_by: nil, is_sort: true},
      %{name: "price_and_delivery", title: "Delivered Price", sort_by: nil, is_sort: true},
      %{name: "delivered", title: "Delivered", sort_by: nil, is_sort: true},
      %{name: "buyer", title: "Buyer", sort_by: nil, is_sort: false},
      %{name: "destination", title: "Destination", sort_by: nil, is_sort: false},
      %{name: "estimated_ship_date", title: "Ship Date", sort_by: nil, is_sort: true},
      %{name: "firm", title: "Firm", sort_by: nil, is_sort: true},
      %{name: "projected_out_date", title: "Kill Date", sort_by: nil, is_sort: true},
      %{name: "projected_break_even", title: "Proj BE", sort_by: nil, is_sort: true},
      %{name: "Shipment", title: "shipment", sort_by: nil, is_sort: false},
      %{name: "complete", title: "Complete", sort_by: nil, is_sort: true}
    ]

    total_pages = Purchases.total_pages(1)

    socket =
      assign_defaults(session, socket)
      |> assign(
        page_title: "Purchase",
        app: "Cattle Purchase",
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
        },
        modal: nil,
        page: 1,
        per_page: 20,
        total_pages: total_pages
      )

    socket = fetch_purchase(socket)

    if connected?(socket) do
      Purchases.subscribe()
    end

    case authenticate(socket) do
      true -> {:ok, socket}
      false -> {:ok, redirect(socket, to: "/")}
    end
  end

  defp fetch_purchase(socket) do
    %{page: page, per_page: per_page} = socket.assigns
    purchases = Purchases.list_purchases_by_page(page, per_page)
    assign(socket, purchases: purchases)
  end

  @impl true
  def handle_params(_, _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:purchases, :deleted], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
    {:noreply, assign(socket, purchases: Purchases.list_purchases())}
  end

  @impl true
  def handle_info({[:purchases, :created_or_updated], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
    {:noreply, assign(socket, purchases: Purchases.list_purchases())}
  end

  @impl true
  def handle_event("new", _, socket) do
    changeset = Purchases.new_purchase()
    purchase_groups = PurchaseGroups.list_purchase_groups()
    purchase_types = PurchaseTypes.get_active_purchase_types()
    destination_groups = Purchases.get_destination("") |> format_destination_group()
    sexes = Sexes.get_active_sexes()
    pcc_sort_category = Purchases.pcc_sort_category()
    purchase_flags = PurchaseFlags.list_purchase_flags()
    purchase_buyers = Purchases.get_buyers("")

    if purchase_groups == [] || purchase_types == [] || destination_groups == [] do
      {:noreply,
       put_flash(
         socket,
         :error,
         "You must create Purchase Groups, Purchase Types, and Destination Groups before adding purchases."
       )}
    else
      socket =
        assign(socket,
          changeset: changeset,
          modal: :change_purchase,
          purchase_groups: Enum.map(purchase_groups, &%{id: &1.id, name: &1.name}),
          purchase_types: Enum.map(purchase_types, &%{id: &1.id, name: &1.name}),
          sexes: Enum.map(sexes, &%{id: &1.id, name: &1.name}),
          pcc_sort_category: pcc_sort_category,
          purchase_flags: Enum.map(purchase_flags, &%{id: &1.id, name: &1.name, checked: false}),
          purchase_buyers: Enum.map(purchase_buyers, &%{id: &1.id, name: &1.name}),
          destinations: destination_groups
        )

      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("clear_filters", _, socket) do
    active_purchase_types =
      PurchaseTypes.get_active_purchase_types()
      |> Enum.map(fn item -> %{id: item.id, name: item.name, checked: false} end)

    purchase_type_filters =
      PurchaseTypeFilters.list_purchase_type_filters()
      |> Enum.map(fn item -> %{id: item.id, name: item.name, checked: false} end)

    toggle_complete = %{name: "toggle completed", checked: false}

    {:noreply,
     assign(socket,
       active_purchase_types: active_purchase_types,
       purchase_type_filters: purchase_type_filters,
       purchases: Purchases.list_purchases(),
       toggle_complete: toggle_complete,
       purchase_search: %{
         column_name: "Select column for search",
         search_value: "",
         start_date: "",
         end_date: ""
       }
     )}
  end

  @impl true
  def handle_event("edit", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    purchases = Enum.find(socket.assigns.purchases, fn pg -> pg.id == id end)
    purchase = purchases |> Repo.preload(:purchase_flags)
    purchase_flags = Enum.map(purchase.purchase_flags, fn item -> item.id end)

    changeset =
      purchases
      |> Purchases.change_purchase()

    purchase_groups = PurchaseGroups.list_purchase_groups()
    purchase_types = PurchaseTypes.get_active_purchase_types()
    destination_groups = Purchases.get_destination("") |> format_destination_group()
    sexes = Sexes.get_active_sexes()
    pcc_sort_category = Purchases.pcc_sort_category()
    purchase_buyers = Purchases.get_buyers("")

    purchase_flags =
      PurchaseFlags.list_purchase_flags()
      |> Enum.map(fn item ->
        result = Enum.find(purchase_flags, nil, fn purchase_flag -> item.id == purchase_flag end)

        if(result) do
          %{id: item.id, name: item.name, checked: true}
        else
          %{id: item.id, name: item.name, checked: false}
        end
      end)

    result = modify_destination_group_for_select(purchases)

    changeset =
      Ecto.Changeset.put_change(changeset, :destination_group_id, result)
      |> Map.put(:action, :update)

    socket =
      assign(socket,
        changeset: changeset,
        modal: :change_purchase,
        purchase_groups: Enum.map(purchase_groups, &%{id: &1.id, name: &1.name}),
        purchase_types: Enum.map(purchase_types, &%{id: &1.id, name: &1.name}),
        sexes: Enum.map(sexes, &%{id: &1.id, name: &1.name}),
        pcc_sort_category: pcc_sort_category,
        purchase_flags: purchase_flags,
        purchase_buyers: Enum.map(purchase_buyers, &%{id: &1.id, name: &1.name}),
        destinations: destination_groups
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", params, socket) do
    {id, ""} = Integer.parse(params["id"])

    Enum.find(socket.assigns.purchases, fn pg -> pg.id == id end)
    |> Purchases.delete_purchase()

    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, modal: nil)
    {:noreply, socket}
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

    purchases =
      Purchases.sort_by(Purchase, sortOrder, selected_column.name)
      |> Repo.all()
      |> Repo.preload([:sex, :purchase_buyer, :destination_group])

    {:noreply, assign(socket, purchases: purchases, sort_columns: sort_columns)}
  end

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
        "validate",
        %{"purchase_search" => purchase_search},
        socket
      ) do
    start_date =
      if !(String.trim(purchase_search["start_date"]) == "") &&
           purchase_search["start_date"] !=
             socket.assigns.purchase_search.start_date do
        purchase_search["start_date"]
      end

    end_date =
      if !(String.trim(purchase_search["end_date"]) == "") &&
           purchase_search["end_date"] !=
             socket.assigns.purchase_search.end_date do
        purchase_search["end_date"]
      end

    search_value =
      if !(String.trim(purchase_search["search_value"]) == "") &&
           purchase_search["search_value"] !=
             socket.assigns.purchase_search.search_value do
        purchase_search["search_value"]
      end

    column_name =
      if purchase_search["column_name"] != "" do
        purchase_search["column_name"]
      else
        "Select column for search"
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

  def handle_event("search", _params, socket) do
    purchase_filters =
      Enum.reduce(socket.assigns.purchase_search, %{}, fn {k, v}, map ->
        if(String.trim(v) == "" || v == "Select column for search") do
          Map.put(map, k, nil)
        else
          Map.put(map, k, v)
        end
      end)

    purchase_types_ids =
      Enum.reduce(socket.assigns.active_purchase_types, [], fn purchase_type, list ->
        if(purchase_type.checked) do
          list ++ [purchase_type.id]
        else
          list
        end
      end)

    purchase_type_filter_ids =
      Enum.reduce(socket.assigns.purchase_type_filters, [], fn purchase_type_filter, list ->
        if(purchase_type_filter.checked) do
          list ++ [purchase_type_filter.id]
        else
          list
        end
      end)

    toggle_completed = if(socket.assigns.toggle_complete.checked, do: true, else: false)

    purchases =
      Purchases.filter_by_purhcase_types(Purchase, purchase_types_ids)
      |> Purchases.filter_by_purchase_type_filter(purchase_type_filter_ids)
      |> Purchases.get_complete_purchases(toggle_completed)
      |> Purchases.ship_date_range(purchase_filters.start_date, purchase_filters.end_date)
      |> Purchases.search(purchase_filters.column_name, purchase_filters.search_value)
      |> Repo.all()
      |> Repo.preload([:sex, :purchase_buyer, :destination_group])

    {:noreply, assign(socket, purchases: purchases)}
  end

  def handle_event(
        "handle_purchase_complete_change",
        params,
        socket
      ) do
    case params do
      %{"id" => id, "value" => value} ->
        change_purchase_complete(socket, params, true)
        {:noreply, socket}

      %{"id" => id} ->
        change_purchase_complete(socket, params, false)
        {:noreply, socket}

      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("load_more_purchases", _, socket) do
    %{page: page, per_page: per_page, total_pages: total_pages} = socket.assigns

    socket =
      cond do
        page < total_pages ->
          page = page + 1
          purchases = Purchases.list_purchases_by_page(page, per_page)
          assign(socket, update_action: "append", page: page, purchases: purchases)

        true ->
          socket
      end

    {:noreply, socket}
  end

  defp format_destination_group(destination_groups) do
    Enum.reduce(destination_groups, [], fn destination_group, acc ->
      acc = acc ++ [%{id: destination_group.id, name: destination_group.name, child: false}]

      small =
        Enum.map(destination_group.destinations, fn item ->
          %{name: item.name, id: destination_group.id, child: true}
        end)

      acc = acc ++ small
    end)
  end

  defp change_purchase_complete(socket, params, value) do
    {id, ""} = Integer.parse(params["id"])
    purchase = Enum.find(socket.assigns.purchases, fn pg -> pg.id == id end)

    changeset =
      purchase
      |> Purchases.create_or_update_purchase(%{complete: value})
  end

  defp format_destination_group(destination_groups) do
    Enum.reduce(destination_groups, [], fn destination_group, acc ->
      acc = acc ++ [%{id: destination_group.id, name: destination_group.name, child: false}]

      small =
        Enum.map(destination_group.destinations, fn item ->
          %{name: item.name, id: destination_group.id, child: true}
        end)

      acc = acc ++ small
    end)
  end

  defp modify_destination_group_for_select(purchase) do
    cond do
      !purchase.destination_group_name ->
        ""

      String.contains?(purchase.destination_group_name, ">") ->
        [parent_name, child_name] =
          String.split(purchase.destination_group_name, ">")
          |> Enum.map(fn item -> String.trim(item) end)

        Integer.to_string(purchase.destination_group_id) <>
          "|" <> child_name

      purchase.destination_group_name == "" ->
        Integer.to_string(purchase.destination_group_id)

      true ->
        Integer.to_string(purchase.destination_group_id)
    end
  end
end
