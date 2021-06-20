defmodule BorrowingBase.LotAdjustments do
  import Ecto.Query

  alias BorrowingBase.{
    EffectiveDate,
    LotAdjustment,
    LotStatusCode,
    MarketValueAdjustments,
    Repo,
    SexCode,
    WeightBreak,
    Yard
  }

  @topic "borrowing_base:lot_adjustment"

  def subscribe(), do: Phoenix.PubSub.subscribe(BorrowingBase.PubSub, @topic)

  def subscribe(id), do: Phoenix.PubSub.subscribe(BorrowingBase.PubSub, "#{@topic}:#{id}")

  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(BorrowingBase.PubSub, @topic)

  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(BorrowingBase.PubSub, "#{@topic}:#{id}")

  def new_lot_adjustment(), do: %LotAdjustment{}

  def get_lot_adjustment!(id), do: Repo.get!(LotAdjustment, id)

  def list_lot_adjustments_with_stream(
        effective_date_id,
        yard_id,
        sort_by \\ "yard_number",
        sort_order \\ "asc",
        search_col \\ nil,
        search \\ "",
        callback) do
    query =
      LotAdjustment
      |> where([la], la.effective_date_id == ^effective_date_id and la.yard_id == ^yard_id)
      |> select([la], [
          la.yard_number,
          la.customer_number,
          la.customer_name,
          la.lot_number,
          la.pen_number,
          la.sex_code,
          la.head_count_current,
          la.average_current_weight,
          la.lot_status_code,
          la.market_value,
          la.total_value
        ])
      |> order_by([la], [{^String.to_atom(sort_order), ^String.to_atom(sort_by)}, asc: la.yard_number, asc: la.lot_number, asc: la.pen_number, asc: la.customer_number])

    query = cond do
      search_col && search_col != "" && search != "" ->
        search = "%#{search}%"
        search_col = String.to_atom(search_col)
        where(query, [la], like(field(la, ^search_col), ^search))
      true -> query
    end

    header = [[
      "Yard Number",
      "Customer Number",
      "Customer Name",
      "Lot Number",
      "Pen Number",
      "Sex Code",
      "Current Head Count",
      "Current Average Weight",
      "Lot Status Code",
      "Market Value",
      "Total Value"
    ]]

    Repo.transaction(fn ->
      stream =
        query
        |> Repo.stream()
      stream = Stream.concat(header, stream)
      callback.(stream)
    end)
  end

  def list_lot_adjustments(
      effective_date_id,
      yard_id,
      sort_by \\ "yard_number",
      sort_order \\ "asc",
      search_col \\ nil,
      search \\ "") do
    query = LotAdjustment
    |> where([la], la.effective_date_id == ^effective_date_id and la.yard_id == ^yard_id)
    |> order_by([la], [{^String.to_atom(sort_order), ^String.to_atom(sort_by)}, asc: la.yard_number, asc: la.lot_number, asc: la.pen_number, asc: la.customer_number])

    query = cond do
      search_col && search_col != "" && search != "" ->
        search = "%#{search}%"
        search_col = String.to_atom(search_col)
        where(query, [la], like(field(la, ^search_col), ^search))
      true -> query
    end

    Repo.all(query)
  end

  def list_lot_adjustments() do
    LotAdjustment
    |> order_by([la], asc: la.yard_number, asc: la.lot_number, asc: la.pen_number, asc: la.customer_number)
    |> Repo.all()
  end

  def create_or_update_lot_adjustment(%LotAdjustment{} = lot_adjustment, attrs \\ %{}) do
    lot_adjustment
    |> LotAdjustment.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:lot_adjustment, :updated])
  end

  def delete_lot_adjustment(%LotAdjustment{} = lot_adjustment) do
    Repo.delete(lot_adjustment)
    |> notify_subscribers([:lot_adjustment, :deleted])
  end

  def change_lot_adjustment(%LotAdjustment{} = lot_adjustment, attrs \\ %{}) do
    LotAdjustment.changeset(lot_adjustment, attrs)
  end

  def pull_update(%EffectiveDate{} = effective_date, %WeightBreak{} = weight_break, %Yard{} = yard) do
    sex_codes =
      SexCode
      |> join(:inner, [sc], wb in "weight_breaks", on: sc.company_id == wb.company_id)
      |> where([sc, wb], wb.id == ^effective_date.weight_break_id)
      |> Repo.all()

    lot_status_codes =
      LotStatusCode
      |> join(:inner, [lsc], wb in "weight_breaks_lot_status_codes", on: lsc.id == wb.lot_status_code_id)
      |> where([lsc, wb], wb.weight_break_id == ^effective_date.weight_break_id)
      |> select([lsc, wb], lsc.lot_status_code)
      |> Repo.all()

    yard_numbers = String.split(yard.yard_number, ",")

    tk_data = from(f6 in "fyf006")
    |> join(:left, [f6], f3 in "fyf003",
      on: f3.yard_number == f6.yard_number
      and f3.lot_number == f6.lot_number
      and f3.yard == f6.yard)
    |> join(:left, [f6, f3], c in "cusmas",
      on: f6.yard == c.yard
      and f6.customer_number == c.associate_number)
    |> select([f6, f3, c], %{
      yard_name: f3.yard,
      yard_number: f3.yard_number,
      customer_number: f6.customer_number,
      customer_name: c.name,
      lot_number: f3.lot_number,
      pen_number: f3.pen_number,
      head_count_current: (f3.hdct_curr * (f6.pct_ownership / 100)),
      sex_code: f3.sex_code,
      average_current_weight: f3.weight_curr_avg,
      lot_status_code: f3.lot_status_code
      })
    |> where([f6, f3, c], f3.lot_status_code in ^lot_status_codes
      and ((f3.hdct_curr * (f6.pct_ownership / 100)) > 0)
      and not like(c.name, "ZZ%")
      and f3.yard_number in ^yard_numbers)
    |> Repo.Turnkey.all()
    |> Enum.map(fn a ->
      gender =
        Enum.find(sex_codes, %{gender: "steer"}, &(String.downcase(&1.sex_code) == String.downcase(a.sex_code)))
        |> Map.get(:gender)

      curr_time =
        DateTime.utc_now()
        |> DateTime.truncate(:second)
        |> DateTime.to_naive()

      Map.put(a, :gender, gender)
      |> Map.put(:customer_number, "#{a.customer_number}")
      |> Map.put(:effective_date_id, effective_date.id)
      |> Map.put(:yard_id, yard.id)
      |> Map.put(:inserted_at, curr_time)
      |> Map.put(:updated_at, curr_time)
    end)

    from(l in LotAdjustment, where: l.yard_id == ^yard.id and l.effective_date_id == ^effective_date.id)
    |> Repo.delete_all()

    Repo.insert_all(LotAdjustment, tk_data)

    MarketValueAdjustments.adjust_lots_market_value(effective_date, weight_break, yard)

    result = %{id: nil, yard_id: yard.id, effective_date_id: effective_date.id}
    {:ok, result}
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(BorrowingBase.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(BorrowingBase.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
