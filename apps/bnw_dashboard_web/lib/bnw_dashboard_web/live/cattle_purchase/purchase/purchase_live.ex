defmodule BnwDashboardWeb.CattlePurchase.Purchase.PurchaseLive do
  use BnwDashboardWeb, :live_view
  alias CattlePurchase.{
    Authorize,
    Purchases,
    PurchaseTypes,
    PurchaseTypeFilters
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
    active_purchase_types = PurchaseTypes.get_active_purchase_types()
      |> Enum.map(fn item -> %{id: item.id, name: item.name, checked: false} end)
    purchase_type_filters = PurchaseTypeFilters.list_purchase_type_filters
      |> Enum.map(fn item -> %{id: item.id, name: item.name, checked: false} end)
    toggle_complete = %{name: "toggle completed", checked: false}
    search_columns = [purchase_date: :purchase_date, seller: :seller,
                      purchase_location: :origin, purchase_order: :purchase_order,
                      head_count: :head_count, sex: :sex, weight: :weight, price: :price,
                      buyer: :buyer, destination: :destination, ship_date: :estimated_ship_date,
                      kill_date: :projected_out_date
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
        search_columns: search_columns

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
  def handle_params(_,_, socket) do
    {:noreply, socket}
  end

  def handle_event(
        "handle_toggle_purchase_type",
        %{"id" => _, "value" => value} = params,
        socket
      ) do
    {id, ""} = Integer.parse(params["id"])
    active_purchase_types =
      socket.assigns.active_purchase_types
      |> Enum.map(fn item ->
        if(item.id == id) do
          Map.put(item, :checked, true)
        else
          item
        end
      end)
    {:noreply, assign(socket, active_purchase_types: active_purchase_types)}
  end

  def handle_event(
        "handle_toggle_purchase_type_filter",
        %{"id" => _, "value" => value} = params,
        socket
      ) do
    {id, ""} = Integer.parse(params["id"])
    purchase_type_filters =
      socket.assigns.purchase_type_filters
      |> Enum.map(fn item ->
        if(item.id == id) do
          Map.put(item, :checked, true)
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
        toggle_complete =   Map.put(socket.assigns.toggle_complete, :checked, true)
        {:noreply, assign(socket, toggle_complete: toggle_complete)}
  end

  def handle_event(
        "validate",
        %{"purchase_search" => purchase_search},
        socket
      ) do

      if !(Map.has_key?(socket.assigns, :start_date)) && !(String.strip(purchase_search["start_date"]) == "") do
        {:noreply, assign(socket, start_date: purchase_search["start_date"])}
      else
        if !(Map.has_key?(socket.assigns, :end_date)) && !(String.strip(purchase_search["end_date"]) == "") do
          {:noreply, assign(socket, end_date: purchase_search["end_date"])}
        else
          if !(Map.has_key?(socket.assigns, :search_value)) && !(String.strip(purchase_search["search_value"]) == "") do
            {:noreply, assign(socket, search_value: purchase_search["search_value"])}
          else
            if !(Map.has_key?(socket.assigns, :column_name)) && (String.strip(purchase_search["column_name"]) == "") do
              {:noreply, assign(socket, column_name: purchase_search["column_name"])}
            else
              {:noreply, socket}
            end
          end
        end
      end
  end


  def handle_event("search", _params, socket) do
    {:noreply, socket}
  end
end
