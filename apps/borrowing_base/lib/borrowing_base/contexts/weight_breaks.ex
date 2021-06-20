defmodule BorrowingBase.WeightBreaks do
  import Ecto.Query

  alias BorrowingBase.{
    EffectiveDate,
    LotStatusCode,
    WeightBreak,
    WeightGroup,
    Price,
    Repo
  }

  @topic "borrowing_base:weight_break"

  def subscribe(), do: Phoenix.PubSub.subscribe(BorrowingBase.PubSub, @topic)

  def subscribe(id), do: Phoenix.PubSub.subscribe(BorrowingBase.PubSub, "#{@topic}:#{id}")

  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(BorrowingBase.PubSub, @topic)

  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(BorrowingBase.PubSub, "#{@topic}:#{id}")

  def new_weight_break(), do: %WeightBreak{}

  def get_weight_break!(id), do: Repo.get!(WeightBreak, id)

  def list_weight_breaks(company_id) do
    WeightBreak
    |> where([sc], sc.company_id == ^company_id)
    |> order_by([sc], asc: :name)
    |> Repo.all()
  end

  def list_weight_breaks() do
    WeightBreak
    |> order_by([sc], asc: :weight_break)
    |> Repo.all()
  end

  def list_lot_status_codes(%WeightBreak{} = weight_break) do
    LotStatusCode
    |> join(:left, [lsc], wblsc in "weight_breaks_lot_status_codes", on: lsc.id == wblsc.lot_status_code_id)
    |> select([lsc, wblsc], %{id: lsc.id,
                              lot_status_code: lsc.lot_status_code,
                              checked: wblsc.weight_break_id == ^weight_break.id})
    |> where([lsc, wblsc], lsc.company_id == ^weight_break.company_id and (wblsc.weight_break_id == ^weight_break.id or is_nil(wblsc.id)))
    |> order_by([lsc, wblsc], asc: lsc.lot_status_code)
    |> Repo.all()
  end

  def create_or_update_weight_break(%WeightBreak{} = weight_break, attrs \\ %{}) do
    weight_break
    |> WeightBreak.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:weight_break, :updated])
  end

  def delete_weight_break(%WeightBreak{} = weight_break) do
    Repo.delete(weight_break)
    |> notify_subscribers([:weight_break, :deleted])
  end

  def add_lot_status_codes(weight_break_id, lot_status_code_id) do
    query = from(
      wblsc in "weight_breaks_lot_status_codes",
      where: wblsc.weight_break_id == ^weight_break_id and wblsc.lot_status_code_id == ^lot_status_code_id)

    lot_status_code =
      query
      |> select([wblsc], %{weight_break_id: wblsc.weight_break_id, lot_status_code_id: wblsc.lot_status_code_id})
      |> first(:id)
      |> Repo.one()

    cond do
      lot_status_code -> Repo.delete_all(query)
      true -> Repo.insert_all("weight_breaks_lot_status_codes", [%{weight_break_id: weight_break_id, lot_status_code_id: lot_status_code_id}])
    end
    notify_subscribers({:ok, %{id: weight_break_id, weight_break_id: weight_break_id}}, [:lot_status_codes, :updated])
  end

  def change_weight_break(%WeightBreak{} = weight_break, attrs \\ %{}) do
    WeightBreak.changeset(weight_break, attrs)
  end

  defp yards(weight_break) do
    from(y in "yards")
    |> where([y], y.company_id == ^weight_break.company_id)
    |> select([y], %{yard: y.external_name, id: y.id})
    |> distinct(true)
    |> Repo.all()
  end

  defp fyf035_columns() do
    from(c in "columns")
    |> where([c], c.table_schema == ^"turnkey" and c.table_name == ^"fyf035")
    |> select([c], c.column_name)
    |> Repo.InformationSchema.all()
    |> Enum.map(&String.to_atom(&1))
  end

  defp fyf035_data(yards_names, columns) do
    from(fyf035 in "fyf035")
    |> where([fyf035], fyf035.yard in ^yards_names)
    |> select([fyf035], map(fyf035, ^columns))
    |> Repo.Turnkey.all()
  end

  def pull_update(%WeightBreak{} = weight_break) do
    yards = yards(weight_break)
    yards_names = yards |> Enum.map(&(&1.yard)) |> Enum.uniq()
    columns = fyf035_columns()
    table = fyf035_data(yards_names, columns)

    effective_dates =
      table
      |> Enum.map(&(%EffectiveDate{effective_date: &1[:EFFECTIVE_DATE], weight_break_id: weight_break.id}))
      |> Enum.uniq()
      |> Enum.map(fn x ->
        {_, ed} = Repo.insert(x, on_conflict: :nothing)
        cond do
          ed.id -> ed
          true ->
            Repo.get_by(EffectiveDate, [effective_date: x.effective_date, weight_break_id: x.weight_break_id, locked: false])
        end
      end)

    effective_date_ids = Enum.map(effective_dates, &(if &1, do: &1.id, else: nil))
    from(wg in WeightGroup, where: wg.effective_date_id in ^effective_date_ids)
    |> Repo.delete_all()

    Enum.map(table, fn wb ->
      effective_date = Enum.find(effective_dates, &(&1 && &1.effective_date == wb[:"EFFECTIVE_DATE"]))
      if effective_date do
        effective_date_id = Map.get(effective_date, :id)
        Map.drop(wb, [:yard, :EFFECTIVE_DATE, :RECORD_NUMBER])
        |> Enum.map(fn {k, v} -> {k |> Atom.to_string |> String.downcase(), v} end)
        |> Enum.group_by(
          fn {k, _} -> k |> String.split("#") |> Enum.at(1) |> String.to_integer() end,
          fn {k, v} ->
              k = String.split(k, "#") |> Enum.at(0)
              k = cond do
                k == "weight_group" -> "min"
                true -> k |> String.split("_") |> Enum.at(0)
              end
              {k, v}
          end
        )
        |> Enum.reverse()
        |> Enum.map_reduce(nil, fn {_k, v}, acc ->
          min = Map.new(v) |> Map.get("min")

          prices =
            Enum.reject(v, fn {k, _v} -> k == "min" end)
            |> Enum.map(fn {k, v} -> %Price{gender: k, amount: v} end)

          Enum.filter(yards, fn y -> y.yard == wb.yard end)
          |> Enum.each(fn y ->
            %WeightGroup{
              min_weight: min,
              max_weight: acc,
              yard_id: y.id,
              effective_date_id: effective_date_id,
              weight_break_id: weight_break.id,
              prices: prices}
            |> Repo.insert()
          end)

          next_max = min - 1
          {v, next_max}
        end)
      end
    end)

    Enum.each(effective_dates, fn e ->
      if e do
        Phoenix.PubSub.broadcast(BorrowingBase.PubSub, "borrowing_base:weight_group", {[:weight_group, :pull_update], e})
      end
    end)
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(BorrowingBase.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(BorrowingBase.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
