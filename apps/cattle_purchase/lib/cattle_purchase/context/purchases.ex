defmodule CattlePurchase.Purchases do
  alias CattlePurchase.{
    Purchase,
    PurchaseType,
    PurchaseTypeFilter,
    PurchaseBuyer,
    Destination,
    DestinationGroup,
    Repo
  }
  import Ecto.Query, only: [from: 2]

  @topic "cattle_purchase:purchases"
  def subscribe(), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, @topic)
  def subscribe(id), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")
  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, @topic)
  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")

  @doc """
  List all purchases
  """

  def list_purchases() do
    Repo.all(Purchase)
    |> Repo.preload([:sex, :purchase_buyer, :destination_group])
  end

  @doc """
  Create a new purchase
  """
  def new_purchase() do
    Purchase.new_changeset(%Purchase{}, %{})
  end

  def change_purchase(%Purchase{} = purchase, attrs \\ %{}) do
    Purchase.changeset(purchase, attrs)
  end

  def validate(%Purchase{} = purchase, attrs \\ %{}) do
    purchase
    |> change_purchase(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a purchase
  """
  def create_or_update_purchase(%Purchase{} = purchase, attrs \\ %{}) do
    purchase
    |> Purchase.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:purchases, :created_or_updated])
  end

  @doc """
  Delete a purchase type
  """
  def delete_purchase(%Purchase{} = purchase) do
    Repo.delete(purchase)
    |> notify_subscribers([:purchases, :deleted])

  end

  def filter_by_purhcase_types(purchase_type_ids) do
    query = from( p in Purchase,
                    join: pt in PurchaseType,
                    on: p.purchase_type_id == pt.id
                )
    Enum.reduce(purchase_type_ids, query, fn purchase_type_id, query ->
      from( [p, ..., q] in query,
            or_where: q.id == ^purchase_type_id
          )
    end)
    |> Repo.all()
  end

  def sort_by(sort_order, field) do
    sort_order = String.to_atom(sort_order)
    field = String.to_atom(field)

    from(p in Purchase,
          order_by: [{^sort_order, ^field}]
        )
        |> Repo.all()
  end

  def get_purchase_type_filters() do
    PurchaseTypeFilter
    |> Repo.all()
  end

  def get_complete_purchases() do
    from(p in Purchase,
          where: p.complete == true
        )
        |> Repo.all()
  end

  def get_buyers(query) do
    from(pb in PurchaseBuyer,
          where: like(pb.name, ^"%#{query}%"),
          select: %{name: pb.name, id: pb.id}
        )
        |> Repo.all()
        |> Enum.map(fn record -> %{id: record.id, name: "#{record.name}-#{record.id}"} end)
  end

  def get_destination(query) do
    from(dg in DestinationGroup,
          left_join: d in Destination,
          on: dg.id == d.destination_group_id,
          where: like(dg.name, ^"%#{query}%"),
          preload: [destinations: :d],
          select: [:name, destinations: [:name]]
        )
        |> Repo.all()
  end

  def search(column, query) do
    column = String.to_atom(column)
    from(p in Purchase,
          where: like(field(p, ^column), ^"%#{query}%")
        )
        |> Repo.all()
  end

  def price_and_delivery(purchase) do
    if purchase.freight do
      purchase.price + purchase.freight
    else
      purchase.price
    end
  end

  def ship_date_range(start_date, nil) do
    from(p in Purchase,
          where: p.estimated_ship_date >= ^start_date
        )
        |> Repo.all()
  end

  def ship_date_range(start_date, end_date) do
    from(p in Purchase,
          where: p.estimated_ship_date >= ^start_date
          and p.estimated_ship_date <= ^end_date
        )
        |> Repo.all()
  end

  def notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end
  def notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
