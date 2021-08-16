defmodule TentativeShip.DataPipeline do
  @moduledoc """
  Handles updating lots from Turnkey, Microbeef, and Cattle Purchase.
  Automatically runs at a specific time.
  """
  use Task

  import Ecto.Query
  import Ecto.Changeset

  alias Ecto.Multi
  alias TentativeShip.{
    Customer,
    LotOwner,
    LotPen,
    Lot,
    Repo,
    PenGradeYield
  }

  # tentative_ship/application.ex starts
  def start_link(_arg) do
    current_time = Time.utc_now()
    wait_time = 1000 * 60 * (30 - rem(current_time.minute, 30))
    Task.start_link(__MODULE__, :poll, [%{wait_time: wait_time}])
  end

  def poll(arg) do
    %{wait_time: wait_time} = arg

    receive do
    after
      wait_time ->
        update_lots()
        curr_time = current_time()
        wait = cond do
          # wait until 6 PST (5 PDT, 3 UTC) to run again
          curr_time.hour > 3 && curr_time.hour < 13 ->
            next =
              curr_time
              |> Map.put(:hour, 13)
              |> Map.put(:minute, 0)
              |> Map.put(:second, 0)
              |> Map.put(:microsecond, {0, 0})
            DateTime.diff(curr_time, next)
          # run at the top and bottom of every hour
          true ->
            1000 * 60 * (30 - rem(curr_time.minute, 30))
        end
        poll(%{wait_time: wait})
    end
  end

  def update_lots() do
    Repo.insert_all(Lot, get_lot_data())
    update_lot_ownerships()
    update_lot_pens()
    update_pen_grade_yields()
    # todo replace with pub sub notify
    IO.puts "==========  lots updated  ============"
  end

  def update_lot_ownerships() do
    ownership = get_lot_ownership_data()
    delete_ownership = from(lo in LotOwner, where: lo.lot_id in ^Enum.map(ownership, &(&1.lot_id)))

    Multi.new()
    |> Multi.delete_all(:delete_all, delete_ownership)
    |> Multi.insert_all(:insert_all, LotOwner, ownership)
    |> Repo.transaction(timeout: 300_000)
  end

  defp get_lot_ownership_data() do
    curr_time = current_time()

    from(l in Lot)
    |> join(:left, [l], f in "fyf006",
      on: l.yard_number == f.yard_number and
        l.lot_number == f.lot_number,
      prefix: "turnkey")
    |> join(:inner, [l, f], c in Customer,
      on: f.customer_number == c.id)
    |> join(:left, [l, f, c], lo in LotOwner,
      on: lo.lot_id == l.id and
        lo.customer_id == f.customer_number and
        lo.ownership_pct == f.pct_ownership)
    |> select([l, f, c, lo],
      %{
        lot_id: l.id,
        customer_id: f.customer_number,
        ownership_pct: f.pct_ownership,
        inserted_at: ^curr_time,
        updated_at: ^curr_time
      })
    |> where([l, f, c, lo], f.yard != ^"cas" and is_nil(lo.id))
    |> group_by([l, f, c, lo], [l.id, f.customer_number, f.pct_ownership])
    |> Repo.all()
  end

  def update_lot_pens() do
    # transfers need to happen before new to avoid duplicates
    lot_pen_transfers()
    |> Enum.reduce(Multi.new(), fn pen_info, multi ->
      changeset = change(pen_info.pen, pen_info.attrs)
      Multi.update(multi, {:pen, "#{changeset.data.id}_#{DateTime.utc_now()}"}, changeset)
    end)
    |> Repo.transaction(timeout: 300_000)

    Enum.chunk_every(new_lot_pens(), 1000)
    |> Enum.reduce(Multi.new, fn pens, multi ->
      Multi.insert_all(multi, "insert_all_#{DateTime.utc_now()}", LotPen, pens)
    end)
    |> Repo.transaction(timeout: 300_000)

    updated_lot_pen_info()
    |> Enum.reduce(Multi.new(), fn pen_info, multi ->
      changeset = change(pen_info.pen, pen_info.attrs)
      Multi.update(multi, {:pen, "#{changeset.data.id}_#{DateTime.utc_now()}"}, changeset)
    end)
    |> Repo.transaction(timeout: 300_000)
  end

  defp lot_pen_transfers() do
    exclude =
      from(fyf003 in "fyf003")
      |> join(:inner, [f], l in Lot,
        on: f.yard_number == l.yard_number and
          f.lot_number == l.lot_number)
      |> join(:inner, [f, l], lp in LotPen,
        on: l.id == lp.lot_id and
          f.pen_number == lp.pen_number and
          (f.pen_number_previous == lp.previous_pen or (is_nil(f.pen_number_previous) and is_nil(lp.previous_pen))))
      |> select([f, l, lp], lp.id)
      |> Repo.Turnkey.all(timeout: 300_000)

    from(fyf003 in "fyf003")
    |> join(:inner, [f], l in Lot,
      on: f.yard_number == l.yard_number and
        f.lot_number == l.lot_number)
    |> join(:inner, [f, l], lp in LotPen,
      on: l.id == lp.lot_id and
        f.pen_number_previous == lp.pen_number)
    |> where([f, l, lp], lp.id not in(^exclude))
    |> select([f, l, lp],
      %{
        pen: lp,
        attrs: %{
          lot_id: l.id,
          lot_name: f.lot_name,
          head_count_in: f.hdct_in,
          head_count_current: f.hdct_curr,
          deads: f.hdct_dead,
          lot_status_code: f.lot_status_code,
          sex_code: f.sex_code,
          pen_number: f.pen_number,
          previous_pen: f.pen_number_previous,
          in_date: f.in_date_avg,
          proj_out_date: f.ship_date_proj,
          pay_weight: f.weight_pay_avg,
          current_weight: f.weight_curr_avg,
          est_ship_weight: f.weight_out_avg_proj,
          origin: f.origin_code,
          sort_group: f.sort_group,
          terminal_sort: f.lm_mkt_group
        }
      })
    |> Repo.Turnkey.all(timeout: 300_000)
  end

  defp new_lot_pens() do
    curr_time = current_time()

    from(f in "fyf003")
    |> join(:inner, [f], l in Lot,
      on: f.yard_number == l.yard_number and
        f.lot_number == l.lot_number)
    |> join(:left, [f, l], lp in LotPen,
      on: f.pen_number == lp.pen_number and
        (f.pen_number_previous == lp.previous_pen or (is_nil(f.pen_number_previous) and is_nil(lp.previous_pen))))
    |> where([f, l, lp], is_nil(lp.id))
    |> select([f, l, lp],
      %{
        lot_id: l.id,
        lot_name: f.lot_name,
        head_count_in: f.hdct_in,
        head_count_current: f.hdct_curr,
        deads: f.hdct_dead,
        lot_status_code: f.lot_status_code,
        sex_code: f.sex_code,
        pen_number: f.pen_number,
        previous_pen: f.pen_number_previous,
        in_date: f.in_date_avg,
        proj_out_date: f.ship_date_proj,
        pay_weight: f.weight_pay_avg,
        current_weight: f.weight_curr_avg,
        est_ship_weight: f.weight_out_avg_proj,
        origin: f.origin_code,
        sort_group: f.sort_group,
        terminal_sort: f.lm_mkt_group,
        inserted_at: ^curr_time,
        updated_at: ^curr_time
      })
    |> Repo.Turnkey.all(timeout: 300_000)
  end

  defp updated_lot_pen_info() do
    from(fyf003 in "fyf003")
    |> join(:inner, [f], l in Lot,
      on: f.yard_number == l.yard_number and
        f.lot_number == l.lot_number)
    |> join(:inner, [f, l], lp in LotPen,
      on: l.id == lp.lot_id and
        f.pen_number == lp.pen_number and
        (f.pen_number_previous == lp.previous_pen or (is_nil(f.pen_number_previous) and is_nil(lp.previous_pen))))
    |> where([f, l, lp], f.lot_name != lp.lot_name)
    |> or_where([f, l, lp], f.hdct_in != lp.head_count_in)
    |> or_where([f, l, lp], f.hdct_curr != lp.head_count_current)
    |> or_where([f, l, lp], f.hdct_dead != lp.deads)
    |> or_where([f, l, lp], f.lot_status_code != lp.lot_status_code)
    |> or_where([f, l, lp], f.sex_code != lp.sex_code)
    |> or_where([f, l, lp], f.in_date_avg != lp.in_date)
    |> or_where([f, l, lp], f.ship_date_proj != lp.proj_out_date)
    |> or_where([f, l, lp], f.weight_pay_avg != lp.pay_weight)
    |> or_where([f, l, lp], f.weight_curr_avg != lp.current_weight)
    |> or_where([f, l, lp], f.weight_out_avg_proj != lp.est_ship_weight)
    |> or_where([f, l, lp], f.origin_code != lp.origin)
    |> or_where([f, l, lp], f.sort_group != lp.sort_group)
    |> or_where([f, l, lp], f.lm_mkt_group != lp.terminal_sort)
    |> select([f, l, lp],
      %{
        pen: lp,
        attrs: %{
          lot_id: l.id,
          lot_name: f.lot_name,
          head_count_in: f.hdct_in,
          head_count_current: f.hdct_curr,
          deads: f.hdct_dead,
          lot_status_code: f.lot_status_code,
          sex_code: f.sex_code,
          pen_number: f.pen_number,
          previous_pen: f.pen_number_previous,
          in_date: f.in_date_avg,
          proj_out_date: f.ship_date_proj,
          pay_weight: f.weight_pay_avg,
          current_weight: f.weight_curr_avg,
          est_ship_weight: f.weight_out_avg_proj,
          origin: f.origin_code,
          sort_group: f.sort_group,
          terminal_sort: f.lm_mkt_group
        }
      })
    |> Repo.Turnkey.all(timeout: 300_000)
  end

  defp get_lot_data() do
    curr_time = current_time()

    from(fyf003 in "fyf003")
    |> join(:left, [fyf003], lot in Lot,
      on: fyf003.yard_number == lot.yard_number and
        fyf003.lot_number == lot.lot_number)
    |> select([fyf003, lot],
      %{
        lot_number: fyf003.lot_number,
        yard_number: fyf003.yard_number,
        active: true,
        inserted_at: ^curr_time,
        updated_at: ^curr_time
      })
    |> where([fyf003, lot], is_nil(lot.id) and not is_nil(fyf003.lot_number) and not is_nil(fyf003.yard_number))
    |> group_by([fyf003, lot], [fyf003.yard_number, fyf003.lot_number])
    |> Repo.Turnkey.all(timeout: 300_000)
  end

  defp update_pen_grade_yields() do
    new_grade_yields()
    |> Enum.chunk_every(1000)
    |> Enum.reduce(Multi.new, fn gy, multi ->
      Multi.insert_all(multi, "insert_all_#{DateTime.utc_now()}", PenGradeYield, gy)
    end)
    |> Repo.transaction(timeout: 300_000)

    updated_grade_yields()
    |> Enum.reduce(Multi.new(), fn gy_info, multi ->
      attrs = Map.put(gy_info.attrs, :ship_reference, "#{gy_info.attrs.ship_reference}")
      changeset = change(gy_info.pen_grade_yield, attrs)
      Multi.update(multi, {:pen_grade_yield, "#{changeset.data.id}_#{DateTime.utc_now()}"}, changeset)
    end)
    |> Repo.transaction(timeout: 300_000)
  end

  defp new_grade_yields() do
    curr_time = current_time()
    from(l in Lot)
    |> join(:inner, [l], p in LotPen, on: l.id == p.lot_id)
    |> join(:left, [l, p], f in "fyf045_1",
      on: l.yard_number == f.yard_number and
        l.lot_number == f.lot_number and
        p.pen_number == f.pen_number)
    |> join(:left, [l, p, f], pgy in PenGradeYield,
      on: pgy.external_unique_key == fragment("concat('tk_', ?, '_', ?)", f.ship_reference, f.sequence))
    |> where([l, p, f, pgy], not is_nil(f.ship_reference) and is_nil(pgy.id) and not is_nil(f.sequence))
    |> select([l, p, f, pgy],
      %{
        ship_reference: f.ship_reference,
        prime_count: f."head_carcass_grade#1",
        choice_count: f."head_carcass_grade#2",
        select_count: f."head_carcass_grade#3",
        no_roll_count: f."head_carcass_grade#4",
        low_grade_count: f."head_carcass_grade#5",
        light_carcass_weight_count: f."head_carcass_weight#1",
        heavy_carcass_weight_count: f."head_carcass_weight#4",
        yield_grade_1_count: f."head_yield_grade#1",
        yield_grade_2_count: f."head_yield_grade#2",
        yield_grade_3_count: f."head_yield_grade#3",
        yield_grade_4_count: f."head_yield_grade#4",
        yield_grade_5_count: f."head_yield_grade#5",
        external_unique_key: fragment("concat('tk_', ?, '_', ?)", f.ship_reference, f.sequence),
        lot_pen_id: p.id,
        inserted_at: ^curr_time,
        updated_at: ^curr_time
      })
    |> Repo.Turnkey.all(timeout: 300_000)
    |> Enum.map(&Map.put(&1, :ship_reference, "#{&1.ship_reference}"))
  end

  defp updated_grade_yields() do
      from(pgy in PenGradeYield)
      |> join(:inner, [pgy], lp in LotPen, on: pgy.lot_pen_id == lp.id)
      |> join(:inner, [pgy, lp], l in Lot, on: lp.lot_id == l.id)
      |> join(:inner, [pgy, lp, l], f in "fyf045_1",
        on: pgy.external_unique_key == fragment("concat('tk_', ?, '_', ?)", f.ship_reference, f.sequence))
      |> join(:left, [pgy, lp, l, f], fl in Lot,
        on: f.yard_number == fl.yard_number and
            f.lot_number == fl.lot_number)
      |> join(:left, [pgy, lp, l, f, fl], flp in LotPen,
        on: fl.id == flp.lot_id and
            f.pen_number == flp.pen_number)
      |> where([pgy, lp, l, f],
        l.yard_number != f.yard_number or
        l.lot_number != f.lot_number or
        fragment("not(? <=> ?)", pgy.prime_count, f."head_carcass_grade#1") or
        fragment("not(? <=> ?)", pgy.choice_count, f."head_carcass_grade#2") or
        fragment("not(? <=> ?)", pgy.select_count, f."head_carcass_grade#3") or
        fragment("not(? <=> ?)", pgy.no_roll_count, f."head_carcass_grade#4") or
        fragment("not(? <=> ?)", pgy.low_grade_count, f."head_carcass_grade#5") or
        fragment("not(? <=> ?)", pgy.light_carcass_weight_count, f."head_carcass_weight#1") or
        fragment("not(? <=> ?)", pgy.heavy_carcass_weight_count, f."head_carcass_weight#4") or
        fragment("not(? <=> ?)", pgy.yield_grade_1_count, f."head_yield_grade#1") or
        fragment("not(? <=> ?)", pgy.yield_grade_2_count, f."head_yield_grade#2") or
        fragment("not(? <=> ?)", pgy.yield_grade_3_count, f."head_yield_grade#3") or
        fragment("not(? <=> ?)", pgy.yield_grade_4_count, f."head_yield_grade#4") or
        fragment("not(? <=> ?)", pgy.yield_grade_5_count, f."head_yield_grade#5"))
      |> select([pgy, lp, l, f, fl, flp],
        %{
          pen_grade_yield: pgy,
          attrs: %{
            id: pgy.id,
            ship_reference: f.ship_reference,
            prime_count: f."head_carcass_grade#1",
            choice_count: f."head_carcass_grade#2",
            select_count: f."head_carcass_grade#3",
            no_roll_count: f."head_carcass_grade#4",
            low_grade_count: f."head_carcass_grade#5",
            light_carcass_weight_count: f."head_carcass_weight#1",
            heavy_carcass_weight_count: f."head_carcass_weight#4",
            yield_grade_1_count: f."head_yield_grade#1",
            yield_grade_2_count: f."head_yield_grade#2",
            yield_grade_3_count: f."head_yield_grade#3",
            yield_grade_4_count: f."head_yield_grade#4",
            yield_grade_5_count: f."head_yield_grade#5",
            external_unique_key: fragment("concat('tk_', ?, '_', ?)", f.ship_reference, f.sequence),
            lot_pen_id: fragment("ifnull(?,?)", flp.id, lp.id)
          }
        })
      |> Repo.Turnkey.all(timeout: 300_000)
  end

  defp current_time() do
    DateTime.utc_now()
    |> DateTime.truncate(:second)
    |> DateTime.to_naive()
  end
end
