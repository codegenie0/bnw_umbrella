defmodule CattlePurchase.Sellers do
  alias CattlePurchase.{
    Seller,
    Repo
  }

  import Ecto.Query

  @topic "cattle_purchase:sellers"
  def subscribe(), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, @topic)
  def subscribe(id), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")
  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, @topic)
  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")

  @doc """
  List all sellers
  """

  def list_sellers() do
    Repo.all(Seller)
    |> Repo.preload([:state])
  end

  def list_sellers_by_page(current_page \\ 1, per_page \\ 5, search \\ "") do
    offset = per_page * (current_page - 1)
    search = "%#{search}%"

    Seller
    |> where(
      [p],
      like(p.producer, ^search) or
        like(p.description, ^search)
    )
    |> offset(^offset)
    |> limit(^per_page)
    |> Repo.all()
    |> Repo.preload([
      :state
    ])
  end

  def total_pages(per_page \\ 5) do
    seller_count =
      Seller
      |> Repo.aggregate(:count, :id)

    (seller_count / per_page)
    |> Decimal.from_float()
    |> Decimal.round(0, :up)
    |> Decimal.to_integer()
  end

  def get_sellers_data_total_pages(per_page \\ 5, search \\ "") do
    search = "%#{search}%"

    seller_count =
      Seller
      |> where(
        [p],
        like(p.producer, ^search) or
          like(p.description, ^search) or
          like(p.seller_location, ^search)
      )
      |> Repo.all()
      |> Enum.count()

    (seller_count / per_page)
    |> Decimal.from_float()
    |> Decimal.round(0, :up)
    |> Decimal.to_integer()
  end

  def get_inactive_sellers() do
    from(s in Seller,
      where: s.active != true,
      preload: [:state]
    )
    |> Repo.all()
  end

  def get_active_sellers() do
    from(s in Seller,
      where: s.active == true,
      preload: [:state]
    )
    |> Repo.all()
  end

  @doc """
  Create a new seller
  """
  def new_seller() do
    Seller.new_changeset(%Seller{}, %{})
  end

  def change_seller(%Seller{} = seller, attrs \\ %{}) do
    Seller.changeset(seller, attrs)
  end

  def validate(%Seller{} = seller, attrs \\ %{}) do
    seller
    |> change_seller(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a seller
  """
  def create_or_update_seller(%Seller{} = seller, attrs \\ %{}) do
    seller
    |> Seller.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:sellers, :created_or_updated])
  end

  @doc """
  Delete a purchase type
  """
  def delete_seller(%Seller{} = seller) do
    Repo.delete(seller)
    |> notify_subscribers([:sellers, :deleted])
  end

  def search_query(query) do
    from(s in Seller,
      where: like(s.producer, ^"%#{query}%"),
      preload: [:state]
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
