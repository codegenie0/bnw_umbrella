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

  def filter_by_purhcase_type(purchase_type_id) do
    from(p in Purchase,
          join: pt in PurchaseType,
          on: p.purchase_type_id == pt.id,
          where: pt.id == ^purchase_type_id
        )
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
        |> Enum.map(fn record -> %{name: "#{record.name}-#{record.id}"} end)
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

  def notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end
  def notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
