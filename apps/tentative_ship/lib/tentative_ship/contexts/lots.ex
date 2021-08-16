defmodule TentativeShip.Lots do
  import Ecto.Query

  alias TentativeShip.{
    Lot,
    Repo,
    Schedule
  }

  @topic "tentative_ship:lots"

  def subscribe(), do: Phoenix.PubSub.subscribe(TentativeShip.PubSub, @topic)

  def subscribe(id), do: Phoenix.PubSub.subscribe(TentativeShip.PubSub, "#{@topic}:#{id}")

  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(TentativeShip.PubSub, @topic)

  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(TentativeShip.PubSub, "#{@topic}:#{id}")

  def new_lot(), do: %Lot{}

  def get_lot!(id), do: Repo.get!(Lot, id)

  def list_lots() do
    Lot
    |> order_by(asc: :name)
    |> Repo.all()
  end

  def create_or_update_lot(%Lot{} = lot, attrs \\ %{}) do
    lot
    |> Lot.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:lot, (if Ecto.get_meta(lot, :state) == :built, do: :created, else: :updated)])
  end

  def delete_lot(%Lot{} = lot) do
    Repo.delete(lot)
    |> notify_subscribers([:lot, :deleted])
  end

  def change_lot(%Lot{} = lot, attrs \\ %{}) do
    Lot.changeset(lot, attrs)
  end

  def get_lots_data_total_pages(schedule_id, per_page \\ 15, search \\ "") do
    schedule =
      Schedule
      |> Repo.get(schedule_id)
      |> Repo.preload(:customers)
      |> Repo.preload(:destinations)
      |> Repo.preload(:lot_status_codes)
      |> Repo.preload(:sex_codes)
      |> Repo.preload(:yard_numbers)

    lot_count =
      base_query(schedule, search)
      |> select([l, lo, c, lp, pgy], l.id)
      |> group_by([l, lo, c, lp, pgy], l.id)
      |> order_by([l, lo, c, lp, pgy], [l.yard_number, l.lot_number])
      |> Repo.all()
      |> Enum.count()

    (lot_count / per_page)
    |> Decimal.from_float()
    |> Decimal.round(0, :up)
    |> Decimal.to_integer()
  end

  def get_lots_data(schedule_id, page \\ 1, per_page \\ 15, search \\ "", sort \\ [%{col: "yard_number", dir: "asc", pos: 1}, %{col: "lot_number", dir: "asc", pos: 2}]) do
    schedule =
      Schedule
      |> Repo.get(schedule_id)
      |> Repo.preload(:customers)
      |> Repo.preload(:destinations)
      |> Repo.preload(:lot_status_codes)
      |> Repo.preload(:sex_codes)
      |> Repo.preload(:yard_numbers)

    lots =
      base_query(schedule, search)
      |> select([l, lo, c, lp, pgy], l.id)
      |> group_by([l, lo, c, lp, pgy], l.id)
      |> order_by(^set_order_by(sort))
      |> offset(^(per_page * (page - 1)))
      |> limit(^per_page)
      |> Repo.all()

    base_query(schedule, search)
    |> select([l, lo, c, lp, pgy], %{lot: l, lot_owner: c, lot_pen: lp, grade_yield: pgy})
    |> where([l, lo, c, lp, pgy], l.id in ^lots)
    |> order_by(^set_order_by(sort))
    |> Repo.all()
    |> Enum.with_index()
    |> Enum.map(fn {e, i} -> Map.put(e, :index, i) end)
    |> Enum.group_by(&(&1.lot), &Map.delete(&1, :lot))
    |> Enum.map(fn {k, v} ->
      index = Enum.reduce(v, nil, fn e, acc -> if e.index <= (acc || e.index), do: e.index, else: acc end)
      {Map.put(k, :index, index), v}
    end)
    |> Enum.sort_by(fn {k, _v} -> k.index end)
    |> Enum.map(fn {k, v} ->
      owners =
        v
        |> Enum.group_by(&(&1.lot_owner))
        |> Enum.map(fn {o, i} ->
          index = Enum.reduce(i, nil, fn e, acc -> if e.index <= (acc || e.index), do: e.index, else: acc end)
          if o, do: Map.put(o, :index, index), else: o
        end)
        |> Enum.reject(&is_nil(&1))
        |> Enum.sort_by(&(&1.index))

      owners_name =
        owners
        |> Enum.reduce("", fn l, acc -> acc <> l.name <> "/" end)
        |> String.replace_suffix("/", "")

      pens =
        v
        |> Enum.group_by(&(&1.lot_pen))
        |> Enum.map(fn {p, pd} ->
          index = Enum.reduce(pd, nil, fn e, acc -> if e.index <= (acc || e.index), do: e.index, else: acc end)

          grade_yields =
            pd
            |> Enum.group_by(&(&1.grade_yield))
            |> Enum.map(fn {gy, _e} ->
              index = Enum.reduce(v, nil, fn e, acc -> if e.index <= (acc || e.index), do: e.index, else: acc end)
              if gy, do: Map.put(gy, :index, index), else: gy
            end)
            |> Enum.reject(&is_nil(&1))
            |> Enum.sort_by(&(&1.index))
          p
          |> Map.put(:grade_yields, grade_yields)
          |> Map.put(:index, index)
        end)
        |> Enum.sort_by(&(&1.index))

      %{hdct_curr: hdct_curr, hdct_in: hdct_in} =
        Enum.reduce(pens, %{hdct_curr: 0, hdct_in: 0}, fn p, acc ->
          %{
            hdct_curr: (p.head_count_current || 0) + acc.hdct_curr,
            hdct_in: (p.head_count_in || 0) + acc.hdct_in
          }
        end)

      k
      |> Map.put(:owners, owners)
      |> Map.put(:owners_name, owners_name)
      |> Map.put(:pens, pens)
      |> Map.put(:head_count_current, hdct_curr)
      |> Map.put(:head_count_in, hdct_in)
      |> Map.put(:open, true)
    end)
  end

  defp set_order_by(sort) do
    Enum.map(sort, fn s ->
      {String.to_atom(s.dir), set_column(s.col)}
    end)
  end

  defp set_column("yard_number"), do: dynamic([l, lo, c, lp, pgy], l.yard_number)
  # keep letters at bottom and pad numbers with 0 to keep order.
  defp set_column("lot_number"), do: dynamic([l, lo, c, lp, pgy], fragment("field(?, ? regexp '[:alpha:]'), LPAD(?, 4, '0')", l.lot_number, l.lot_number, l.lot_number))
  # keep letters at bottom and pad numbers with 0 to keep order.
  defp set_column("pen_number"), do: dynamic([l, lo, c, lp, pgy], fragment("field(?, ? regexp '[:alpha:]'), LPAD(?, 4, '0')", lp.pen_number, lp.pen_number, lp.pen_number))
  defp set_column("customer"), do: dynamic([l, lo, c, lp, pgy], c.name)
  defp set_column("date_in"), do: dynamic([l, lo, c, lp, pgy], lp.in_date)
  defp set_column("proj_out_date"), do: dynamic([l, lo, c, lp, pgy], lp.proj_out_date)
  defp set_column("pay_weight"), do: dynamic([l, lo, c, lp, pgy], lp.pay_weight)
  defp set_column("current_weight"), do: dynamic([l, lo, c, lp, pgy], lp.current_weight)
  defp set_column("est_ship_weight"), do: dynamic([l, lo, c, lp, pgy], lp.est_ship_weight)
  defp set_column("origin"), do: dynamic([l, lo, c, lp, pgy], lp.origin)
  defp set_column("terminal_sort"), do: dynamic([l, lo, c, lp, pgy], lp.terminal_sort)
  defp set_column("head_count_in"), do: dynamic([l, lo, c, lp, pgy], lp.head_count_in)
  defp set_column("head_count_current"), do: dynamic([l, lo, c, lp, pgy], lp.head_count_current)
  defp set_column(_), do: ""

  defp base_query(schedule, search) do
    search = "%#{search}%"

    Lot
    |> join(:left, [l], lo in assoc(l, :lot_owners))
    |> join(:left, [l, lo], c in assoc(lo, :customer))
    |> join(:left, [l, lo, c], lp in assoc(l, :lot_pens))
    |> join(:left, [l, lo, c, lp], pgy in assoc(lp, :pen_grade_yields))
    |> query_customers(Enum.map(schedule.customers, &(&1.id)))
    |> query_lot_status_codes(Enum.map(schedule.lot_status_codes, &(&1.name)))
    |> query_sex_codes(Enum.map(schedule.sex_codes, &(&1.name)))
    |> query_yard_numbers(Enum.map(schedule.yard_numbers, &(&1.name)))
    |> where([l, lo, c, lp], lp.head_count_current > 0)
    |> where([l, lo, c, lp],
      like(l.yard_number, ^search) or
      like(l.lot_number, ^search) or
      like(lp.pen_number, ^search) or
      like(c.name, ^search) or
      like(lp.terminal_sort, ^search) or
      like(lp.in_date, ^search) or #todo make date search format mm-dd-yyyy or mm/dd/yyyy
      like(lp.proj_out_date, ^search) or #todo make date search format mm-dd-yyyy or mm/dd/yyyy
      like(lp.origin, ^search)
    )
  end

  defp query_customers(query, []), do: query

  defp query_customers(query, customers) do
    where(query, [l, lo, c, lp, pgy], lo.customer_id in ^customers)
  end

  defp query_lot_status_codes(query, []), do: query

  defp query_lot_status_codes(query, lot_status_codes) do
    where(query, [l, lo, c, lp, pgy], lp.lot_status_code in ^lot_status_codes)
  end

  defp query_sex_codes(query, []), do: query

  defp query_sex_codes(query, sex_codes) do
    where(query, [l, lo, c, lp, pgy], lp.sex_code in ^sex_codes)
  end

  defp query_yard_numbers(query, []), do: query

  defp query_yard_numbers(query, yard_numbers) do
    where(query, [l, lo, c, lp, pgy], l.yard_number in ^yard_numbers)
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(TentativeShip.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(TentativeShip.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
