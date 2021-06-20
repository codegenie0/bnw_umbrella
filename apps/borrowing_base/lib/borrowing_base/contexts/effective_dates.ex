defmodule BorrowingBase.EffectiveDates do
  import Ecto.Query

  alias BorrowingBase.{
    EffectiveDate,
    WeightGroup,
    WeightGroups,
    Price,
    Repo
  }

  @topic "borrowing_base:effective_date"

  def subscribe(), do: Phoenix.PubSub.subscribe(BorrowingBase.PubSub, @topic)

  def subscribe(id), do: Phoenix.PubSub.subscribe(BorrowingBase.PubSub, "#{@topic}:#{id}")

  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(BorrowingBase.PubSub, @topic)

  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(BorrowingBase.PubSub, "#{@topic}:#{id}")

  def new_effective_date(), do: %EffectiveDate{}

  def get_effective_date!(id), do: Repo.get!(EffectiveDate, id)

  def list_effective_dates(weight_break, current_page \\ 1, per_page \\ 10, search \\ "") do
    search = "%#{search}%"
    EffectiveDate
    |> where([ed], ed.weight_break_id == ^weight_break.id and like(ed.effective_date, ^search))
    |> order_by([ed], desc: :effective_date)
    |> offset(^(per_page * (current_page - 1)))
    |> limit(^per_page)
    |> Repo.all()
  end

  def total_pages(weight_break, per_page \\ 10, search \\ "") do
    search = "%#{search}%"
    effective_date_count =
      EffectiveDate
      |> where([ed], ed.weight_break_id == ^weight_break.id and like(ed.effective_date, ^search))
      |> Repo.aggregate(:count, :id)

    (effective_date_count / per_page)
    |> Decimal.from_float()
    |> Decimal.round(0, :up)
    |> Decimal.to_integer()
  end

  def create_or_update_effective_date(%EffectiveDate{} = effective_date, attrs \\ %{}) do
    effective_date
    |> EffectiveDate.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:effective_date, (if Ecto.get_meta(effective_date, :state) == :built, do: :created, else: :updated)])
  end

  def copy_effective_date(%EffectiveDate{} = old_date, %EffectiveDate{} = new_date, attrs \\ %{}) do
    {result, ned} = new_date
    |> EffectiveDate.changeset(attrs)
    |> Repo.insert_or_update()

    if result == :ok do
      from(wg in WeightGroup)
        |> join(:left, [wg], p in Price, on: wg.id == p.weight_group_id)
        |> where([wg, p], wg.effective_date_id == ^old_date.id)
        |> select([wg, p], {wg, p})
        |> Repo.all()
        |> Enum.group_by(
          fn {k, _v} -> k end,
          fn {_k, v} -> %Price{amount: v.amount, gender: v.gender} end)
        |> Enum.each(fn {k, v} ->
          wg = %WeightGroup{
            effective_date_id: ned.id,
            max_weight: k.max_weight,
            min_weight: k.min_weight,
            weight_break_id: k.weight_break_id,
            yard_id: k.yard_id,
            prices: v
          }
          WeightGroups.create_or_update_weight_group(wg)
        end)
    end

    notify_subscribers({result, ned}, [:effective_date, :updated])
  end

  def delete_effective_date(%EffectiveDate{} = effective_date) do
    Repo.delete(effective_date)
    |> notify_subscribers([:effective_date, :deleted])
  end

  def change_effective_date(%EffectiveDate{} = effective_date, attrs \\ %{}) do
    EffectiveDate.changeset(effective_date, attrs)
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(BorrowingBase.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(BorrowingBase.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
