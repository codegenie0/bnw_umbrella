defmodule BorrowingBase.WeightGroups do
  import Ecto.Query

  alias BorrowingBase.{
    Price,
    SexCode,
    WeightGroup,
    Yard,
    Repo
  }

  @topic "borrowing_base:weight_group"

  def subscribe(), do: Phoenix.PubSub.subscribe(BorrowingBase.PubSub, @topic)

  def subscribe(id), do: Phoenix.PubSub.subscribe(BorrowingBase.PubSub, "#{@topic}:#{id}")

  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(BorrowingBase.PubSub, @topic)

  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(BorrowingBase.PubSub, "#{@topic}:#{id}")

  def new_weight_group(yard, effective_date, weight_break) do
    %WeightGroup{
      yard: yard,
      yard_id: yard.id,
      effective_date: effective_date,
      effective_date_id: effective_date.id,
      weight_break: weight_break,
      weight_break_id: weight_break.id
    }
  end

  def new_weight_group(), do: %WeightGroup{}

  def get_weight_group!(id), do: Repo.get!(WeightGroup, id)

  def list_weight_groups(yard, effective_date) do
    WeightGroup
    |> where([wg], wg.yard_id == ^yard and wg.effective_date_id == ^effective_date)
    |> join(:left, [wg], p in assoc(wg, :prices))
    |> preload([wg, p], [prices: p])
    |> order_by([wg, p], asc: wg.min_weight, desc: fragment("field(?, 'heifer', 'steer')", p.gender))
    |> Repo.all()
  end

  def create_or_update_weight_group(%WeightGroup{} = weight_group, attrs \\ %{}) do
    cond do
      Map.get(weight_group, :id) ->
        weight_group
        |> WeightGroup.changeset(attrs)
        |> Repo.insert_or_update()
        |> notify_subscribers([:weight_group, :updated])
      true ->
        prices = Map.get(attrs, "prices")
        {weight_group, attrs} = cond do
          prices ->
            attrs = Map.delete(attrs, "prices")
            wg_prices =
              Map.get(weight_group, :prices)
              |> Enum.map(fn p ->
                {_, amount} = Enum.find(prices, fn {_, v} -> Map.get(v, "gender") == p.gender end)
                {amount, _} =
                  Map.get(amount, "amount")
                  |> Float.parse()
                Map.put(p, :amount, amount)
              end)
            weight_group = Map.put(weight_group, :prices, wg_prices)
            {weight_group, attrs}
          true ->
            {weight_group, attrs}
        end

        weight_group
        |> WeightGroup.changeset(attrs)
        |> Repo.insert_or_update()
        |> notify_subscribers([:weight_group, :updated])
    end
  end

  def delete_weight_group(%WeightGroup{} = weight_group) do
    Repo.delete(weight_group)
    |> notify_subscribers([:weight_group, :deleted])
  end

  def change_weight_group(%WeightGroup{} = weight_group, attrs \\ %{}) do
    WeightGroup.changeset(weight_group, attrs)
  end

  def add_prices(%WeightGroup{} = weight_group) do
    company_id = Map.get(weight_group.yard, :company_id)
    prices =
      SexCode
      |> where([s], s.company_id == ^company_id)
      |> select([s], s.gender)
      |> distinct(true)
      |> order_by([s], desc: fragment("field(?, 'heifer', 'steer')", s.gender))
      |> Repo.all()
      |> Enum.map(&(%Price{gender: &1, amount: 0}))
    Map.put(weight_group, :prices, prices)
  end

  def duplicate_to_yards(yard, effective_date) do
    yards =
      from(y in Yard, where: y.company_id == ^yard.company_id and y.id != ^yard.id)
      |> Repo.all()

    yards_ids = Enum.map(yards, &(&1.id))

    from(wg in WeightGroup, where: wg.yard_id in ^yards_ids and wg.effective_date_id == ^effective_date.id)
    |> Repo.delete_all()

    weight_groups =
      from(wg in WeightGroup, where: wg.yard_id == ^yard.id and wg.effective_date_id == ^effective_date.id)
      |> preload([wg, p], [:prices])
      |> Repo.all()

    Enum.each(yards, fn y ->
      Enum.each(weight_groups, fn wg ->
        prices = Enum.map(wg.prices, fn p ->
          %Price{
            gender: p.gender,
            amount: p.amount
          }
        end)

        new_weight_group = %WeightGroup{
          yard: y,
          yard_id: y.id,
          effective_date: effective_date,
          effective_date_id: effective_date.id,
          prices: prices,
          weight_break_id: wg.weight_break_id
        }

        {prices_attrs, _} = Enum.map_reduce(prices, 0, fn p, acc ->
          price = {"#{acc}", %{"amount" => "#{p.amount}", "gender" => p.gender}}
          {price, acc + 1}
        end)

        attrs = %{
          "max_weight" => wg.max_weight,
          "min_weight" => wg.min_weight,
          "prices" => prices_attrs
        }

        create_or_update_weight_group(new_weight_group, attrs)
      end)
    end)
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(BorrowingBase.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(BorrowingBase.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
