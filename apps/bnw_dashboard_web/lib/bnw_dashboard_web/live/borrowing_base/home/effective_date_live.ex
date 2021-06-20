defmodule BnwDashboardWeb.BorrowingBase.Home.EffectiveDateLive do
  use BnwDashboardWeb, :live_view

  alias BorrowingBase.{
    EffectiveDates,
    LotAdjustments,
    MarketValueAdjustments,
    Yards
  }

  alias BnwDashboardWeb.BorrowingBase.Home.{
    MarketValueAdjustmentsComponent,
    Reports.ReportsLive
  }
  alias BnwDashboardWeb.Router.Helpers, as: Routes

  defp fetch_yards(socket) do
    %{
      weight_break: weight_break,
      current_user: current_user,
      user_roles: user_roles
    } = socket.assigns
    yards = cond do
      current_user.it_admin ->
        Yards.list_yards(weight_break.company_id)
      Enum.any?(user_roles, &(&1.app_admin)) ->
        Yards.list_yards(weight_break.company_id)
      Enum.any?(user_roles, &(&1.company_id == weight_break.company_id && &1.company_admin)) ->
        Yards.list_yards(weight_break.company_id)
      true ->
        Yards.list_yards(weight_break.company_id, current_user.id)
    end

    assign(socket, yards: yards)
  end

  defp fetch_lot_adjustments(socket) do
    %{
      effective_date: effective_date,
      yard: yard,
      sort_by: sort_by,
      sort_order: sort_order,
      search_col: search_col,
      search: search
    } = socket.assigns

    lot_adjustments = LotAdjustments.list_lot_adjustments(
      effective_date.id,
      Map.get(yard, :id),
      sort_by,
      sort_order,
      search_col,
      search)

    total_head_count = Enum.reduce(lot_adjustments, 0, fn la, acc -> Decimal.add(acc, la.head_count_current) end)

    assign(socket, lot_adjustments: lot_adjustments, total_head_count: total_head_count)
  end

  @impl true
  def mount(_params, session, socket) do
    %{
      "effective_date" => effective_date,
      "weight_break" => weight_break,
      "current_user" => current_user,
      "user_roles" => user_roles
    } = session

    search_opt =
      [
        [key: "Yard Number", value: "yard_number"],
        [key: "Lot Number", value: "lot_number"],
        [key: "Pen Number", value: "pen_number"],
        [key: "Customer Number", value: "customer_number"],
        [key: "Customer Name", value: "customer_name"],
        [key: "Current Head Count", value: "head_count_current"],
        [key: "Sex Code", value: "sex_code"],
        [key: "Sex", value: "gender"],
        [key: "Lot Status Code", value: "lot_status_code"],
        [key: "Current Average Weight", value: "average_current_weight"],
        [key: "Market Value", value: "market_value"],
        [key: "Total Value", value: "total_value"]
      ]
      |> Enum.sort(&(&1[:key] <= &2[:key]))

    search_opt = [[key: "Choose a Column to Search", value: ""]] ++ search_opt

    socket =
      assign(socket,
        current_user: current_user,
        effective_date: effective_date,
        weight_break: weight_break,
        modal: nil,
        search_col: "",
        search: "",
        action: "replace",
        user_roles: user_roles,
        sort_by: "yard_number",
        sort_order: "asc",
        search_opt: search_opt,
        total_head_count: 0)
      |> fetch_yards()

    %{yards: yards} = socket.assigns
    yard = (Enum.at(yards, 0) || %{})

    socket =
      assign(socket, yard: yard)
      |> fetch_lot_adjustments()

    if connected?(socket) do
       EffectiveDates.subscribe()
       MarketValueAdjustments.subscribe()
       LotAdjustments.subscribe()
    end
    {:ok, socket}
  end

  # handle params
  # end handle params

  # handle info
  @impl true
  def handle_info({:save, _params}, socket) do
    socket = assign(socket, modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:market_value_adjustments, :updated], result}, socket) do
    %{effective_date: effective_date, yard: yard, modal: modal, current_user: current_user} = socket.assigns
    cond do
      result.effective_date_id == effective_date.id && result.yard_id == yard.id && modal == :adjustments ->
        send_update MarketValueAdjustmentsComponent, id: current_user.id, effective_date: effective_date, yard: yard
        {:noreply, socket}
      true ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info({[:lot_adjustment, :pull_update], result}, socket) do
    %{effective_date: effective_date, yard: yard} = socket.assigns
    cond do
      effective_date.id == result.effective_date_id && yard.id == result.yard_id ->
        lot_adjustments = LotAdjustments.list_lot_adjustments(effective_date.id, yard.id)
        socket = assign(socket, lot_adjustments: lot_adjustments)
        {:noreply, socket}
      true ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info({[:effective_date, :updated], result}, socket) do
    %{effective_date: effective_date} = socket.assigns
    socket = cond do
      effective_date.id == result.id -> assign(socket, effective_date: result)
      true -> socket
    end
    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end
  # end handle info

  # handle event
  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_event("update_lots", _, socket) do
    %{effective_date: effective_date, yard: yard, weight_break: weight_break} = socket.assigns
    LotAdjustments.pull_update(effective_date, weight_break, yard)
    {:noreply, socket}
  end

  @impl true
  def handle_event("update_values", _, socket) do
    %{effective_date: effective_date, yard: yard, weight_break: weight_break} = socket.assigns
    MarketValueAdjustments.adjust_lots_market_value(effective_date, weight_break, yard)
    {:noreply, socket}
  end

  @impl true
  def handle_event("yard", %{"id" => id}, socket) do
    %{yards: yards, effective_date: effective_date} = socket.assigns
    yard = Enum.find(yards, &("#{&1.id}" == id))
    lot_adjustments = LotAdjustments.list_lot_adjustments(effective_date.id, yard.id)
    socket = assign(socket, yard: yard, lot_adjustments: lot_adjustments)
    {:noreply, socket}
  end

  @impl true
  def handle_event("adjustments", _, socket) do
    socket = assign(socket, modal: :adjustments)
    {:noreply, socket}
  end

  @impl true
  def handle_event("reports", _, socket) do
    socket = assign(socket, modal: :reports)
    {:noreply, socket}
  end

  @impl true
  def handle_event("change_locked", _, socket) do
    %{effective_date: effective_date} = socket.assigns
    EffectiveDates.create_or_update_effective_date(effective_date, %{"locked" => !effective_date.locked})
    {:noreply, socket}
  end

  @impl true
  def handle_event("search", %{"search" => params}, socket) do
    %{"search" => search, "search_col" => search_col} = params
    socket =
      socket
      |> assign(search: search, search_col: search_col)
      |> fetch_lot_adjustments()
    {:noreply, socket}
  end

  @impl true
  def handle_event("sort", %{"column" => column}, socket) do
    %{sort_order: sort_order, sort_by: sort_by} = socket.assigns
    sort_order = cond do
      sort_by == column && sort_order == "asc" -> "desc"
      true -> "asc"
    end
    socket =
      assign(socket, sort_order: sort_order, sort_by: column)
      |> fetch_lot_adjustments()
    {:noreply, socket}
  end
  # end handle event
end
