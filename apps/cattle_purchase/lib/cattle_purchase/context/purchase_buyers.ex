defmodule CattlePurchase.PurchaseBuyers do
  alias CattlePurchase.{
    PurchaseBuyer,
    Repo
  }
  import Ecto.Query, only: [from: 2]

  @topic "cattle_purchase:purchase_buyers"
  def subscribe(), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, @topic)
  def subscribe(id), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")
  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, @topic)
  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")

  @doc """
  List all purchase_buyers
  """

  def list_purchase_buyers() do
    Repo.all(PurchaseBuyer)
  end

  @doc """
  Create a new purchase_buyer
  """
  def new_purchase_buyer() do
    PurchaseBuyer.new_changeset(%PurchaseBuyer{}, %{})
  end

  def change_purchase_buyer(%PurchaseBuyer{} = purchase_buyer, attrs \\ %{}) do
    PurchaseBuyer.changeset(purchase_buyer, attrs)
  end

  def validate(%PurchaseBuyer{} = purchase_buyer, attrs \\ %{}) do
    purchase_buyer
    |> change_purchase_buyer(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a purchase_buyer
  """
  def create_or_update_purchase_buyer(%PurchaseBuyer{} = purchase_buyer, attrs \\ %{}) do
    purchase_buyer
    |> PurchaseBuyer.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:purchase_buyers, :created_or_updated])
  end

  @doc """
  Delete a purchase type
  """
  def delete_purchase_buyer(%PurchaseBuyer{} = purchase_buyer) do
    Repo.delete(purchase_buyer)
    |> notify_subscribers([:purchase_buyers, :deleted])

  end

  def search_query(query) do
    from(pb in PurchaseBuyer,
          where: like(pb.name, ^"%#{query}%")
        )
        |> Repo.all()
  end

  def sort_by(sort_order) do
    sort_order = String.to_atom(sort_order)
    from(pb in PurchaseBuyer,
          order_by: [{^sort_order, :name}]
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
