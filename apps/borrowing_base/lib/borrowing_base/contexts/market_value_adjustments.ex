defmodule BorrowingBase.MarketValueAdjustments do
  import Ecto.Query

  alias BorrowingBase.{
    LotAdjustment,
    LotAdjustments,
    LotStatusCode,
    MarketValueAdjustment,
    Repo,
    SexCode,
    WeightBreak,
    WeightGroup,
    Price
  }

  @topic "borrowing_base:market_value_adjustment"

  def subscribe(), do: Phoenix.PubSub.subscribe(BorrowingBase.PubSub, @topic)

  def subscribe(id), do: Phoenix.PubSub.subscribe(BorrowingBase.PubSub, "#{@topic}:#{id}")

  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(BorrowingBase.PubSub, @topic)

  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(BorrowingBase.PubSub, "#{@topic}:#{id}")

  def new_market_value_adjustment(), do: %MarketValueAdjustment{lot_status_codes: []}

  def get_market_value_adjustment!(id), do: Repo.get!(MarketValueAdjustment, id)

  def list_market_value_adjustments(effective_date_id, yard_id) do
    MarketValueAdjustment
    |> join(:left, [mva], lsc in assoc(mva, :lot_status_codes))
    |> preload([mva, lsc], [lot_status_codes: lsc])
    |> where([mva, lsc], mva.effective_date_id == ^effective_date_id and mva.yard_id == ^yard_id)
    |> order_by([mva, lsc], mva.id)
    |> Repo.all()
  end

  def list_market_value_adjustments() do
    MarketValueAdjustment
    |> order_by([sc], asc: :market_value_adjustment)
    |> Repo.all()
  end

  def list_lot_status_codes(effective_date) do
    LotStatusCode
    |> join(:left, [lsc], wblsc in "weight_breaks_lot_status_codes", on: lsc.id == wblsc.lot_status_code_id)
    |> join(:left, [lsc, wblsc], wb in WeightBreak, on: wblsc.weight_break_id == wb.id)
    |> where([lsc, wblsc, wb, alsc], wb.id == ^effective_date.weight_break_id)
    |> order_by([lsc, wblsc, wb, alsc], asc: lsc.lot_status_code)
    |> Repo.all()
  end

  def list_sex_codes(effective_date) do
    SexCode
    |> join(:left, [sc], wb in WeightBreak, on: sc.company_id == wb.company_id)
    |> where([sc, wb], wb.id == ^effective_date.weight_break_id)
    |> select([sc, wb], sc.gender)
    |> order_by([sc, wb], desc: fragment("field(?, 'heifer', 'steer')", sc.gender))
    |> distinct(true)
    |> Repo.all()
  end

  def create_or_update_market_value_adjustment(%MarketValueAdjustment{} = market_value_adjustment, attrs \\ %{}) do
    market_value_adjustment
    |> MarketValueAdjustment.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:market_value_adjustment, :updated])
  end

  def save_adjustments(adjustments, effective_date, yard, weight_break, refresh_lots \\ false) do
    {delete_adjustments, adjustments} = Enum.split_with(adjustments, &(&1.action == :delete))
    {adjustments_ids, lot_status_codes} = Enum.map_reduce(adjustments, [], fn changeset, acc ->
      %{lot_status_codes: lot_status_codes} = changeset
      changeset = Map.put(changeset, :action, nil)
      case Repo.insert_or_update(changeset) do
        {:ok, adjustment} ->
          joins = Enum.map(lot_status_codes, fn lot_status_code ->
            %{
              market_value_adjustment_id: adjustment.id,
              lot_status_code_id: lot_status_code
            }
          end)
          {adjustment.id, acc ++ joins}
        {:error, _changeset} ->
          {nil, acc}
      end
    end)

    delete_adjustments = Enum.map(delete_adjustments, &(&1.data.id))

    from(mva in MarketValueAdjustment, where: mva.id in ^delete_adjustments)
    |> Repo.delete_all()

    from(alsc in "adjustments_lot_status_codes", where: alsc.market_value_adjustment_id in ^adjustments_ids)
    |> Repo.delete_all()

    Repo.insert_all("adjustments_lot_status_codes", lot_status_codes)

    cond do
      refresh_lots -> LotAdjustments.pull_update(effective_date, weight_break, yard)
      true -> adjust_lots_market_value(effective_date, weight_break, yard)
    end

    result = %{id: nil, effective_date_id: effective_date.id, yard_id: yard.id}
    notify_subscribers({:ok, result}, [:market_value_adjustments, :updated])
  end

  def reset_market_values(effective_date, weight_break, yard) do
    reset_query = base_query(effective_date, weight_break, yard)
    reset_query = from([la, wg, p] in reset_query, update: [set: [
      market_value: p.amount,
      total_value: p.amount * la.head_count_current * la.average_current_weight / 100.0
    ]])
    Repo.update_all(reset_query, [])
  end

  def base_query(effective_date, weight_break, yard) do
    from(la in LotAdjustment)
    |> join(:inner, [la], wg in WeightGroup, on:
      la.yard_id == wg.yard_id
      and la.effective_date_id == wg.effective_date_id
      and fragment("? >= ? and ((? < ? + 1) or (? is null))", la.average_current_weight, wg.min_weight, la.average_current_weight, wg.max_weight, wg.max_weight))
    |> join(:inner, [la, wg], p in Price, on:
      wg.id == p.weight_group_id
      and la.gender == p.gender)
    |> where([la, wg, p], la.effective_date_id == ^effective_date.id and la.yard_id == ^yard.id and wg.weight_break_id == ^weight_break.id)
  end

  def adjust_lots_market_value(effective_date, weight_break, yard) do
    reset_market_values(effective_date, weight_break, yard)

    list_market_value_adjustments(effective_date.id, yard.id)
    |> Enum.reverse()
    |> Enum.reduce([], fn adjustment, acc ->
      lot_status_codes = Enum.map(adjustment.lot_status_codes, &(&1.lot_status_code))

      query = base_query(effective_date, weight_break, yard)

      query = cond do
        Enum.empty?(lot_status_codes) -> query
        true ->
          from([la, wg, p] in query, where: la.lot_status_code in ^lot_status_codes)
      end

      query = cond do
        adjustment.gender ->
          genders = String.split(adjustment.gender, ",")
          from([la, wg, p] in query, where: la.gender in ^genders)
        true -> query
      end

      query = cond do
        adjustment.customer_number ->
          from([la, wg, p] in query, where: la.customer_number == ^adjustment.customer_number)
        true -> query
      end

      cond do
        adjustment.amount ->
          query = from(la in query, where: la.id not in ^acc)
          updates =
            query
            |> Repo.all()
            |> Enum.map(&(&1.id))
          query = case adjustment.adjustment_type do
            "percentage" ->
              from([la, wg, p] in query, update: [set: [
                market_value: p.amount + (p.amount * (1.0 * ^adjustment.amount / 100)),
                total_value: (p.amount + (p.amount * (1.0 * ^adjustment.amount / 100))) * la.head_count_current * la.average_current_weight / 100.0
              ]])
            "increment" ->
              from([la, wg, p] in query, update: [set: [
                market_value: p.amount + ^adjustment.amount,
                total_value: (p.amount + ^adjustment.amount) * la.head_count_current * la.average_current_weight / 100.0
              ]])
            "head" ->
              from([la, wg, p] in query, update: [set: [
                market_value: ^adjustment.amount,
                total_value: ^adjustment.amount * la.head_count_current
              ]])
            "replace" ->
              from([la, wg, p] in query, update: [set: [
                market_value: ^adjustment.amount,
                total_value: ^adjustment.amount * la.head_count_current * la.average_current_weight / 100.0
              ]])
            _ ->
              from([la, wg, p] in query, update: [set: [
                market_value: p.amount,
                total_value: p.amount * la.head_count_current * la.average_current_weight / 100.0
              ]])
          end
          Repo.update_all(query, [])
          acc ++ updates
        true -> acc
      end
    end)
    result = %{id: nil, yard_id: yard.id, effective_date_id: effective_date.id}
    event = [:lot_adjustment, :pull_update]
    Phoenix.PubSub.broadcast(BorrowingBase.PubSub, "borrowing_base:lot_adjustment", {event, result})
    Phoenix.PubSub.broadcast(BorrowingBase.PubSub, "borrowing_base:lot_adjustment:#{result.id}", {event, result})
  end

  def delete_market_value_adjustment(%MarketValueAdjustment{} = market_value_adjustment) do
    Repo.delete(market_value_adjustment)
    |> notify_subscribers([:market_value_adjustment, :deleted])
  end

  def change_market_value_adjustment(%MarketValueAdjustment{} = market_value_adjustment, attrs \\ %{}) do
    MarketValueAdjustment.changeset(market_value_adjustment, attrs)
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(BorrowingBase.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(BorrowingBase.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
