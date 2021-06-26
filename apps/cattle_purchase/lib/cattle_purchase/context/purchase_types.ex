defmodule CattlePurchase.PurchaseTypes do
  alias CattlePurchase.{
    PurchaseType,
    Repo
  }

  import Ecto.Query, only: [from: 2]
  @topic "cattle_purchase:purchase_types"

  def subscribe(), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, @topic)
  def subscribe(id), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")
  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, @topic)
  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")

  @doc """
  List all purchase_types
  """

  def list_purchase_types() do
    Repo.all(PurchaseType)
  end

  def get_inactive_purchase_types() do
    query =
      from p in PurchaseType,
        where: p.active != true,
        select: p

    Repo.all(query)
  end

  def get_active_purchase_types() do
    query =
      from p in PurchaseType,
        where: p.active == true,
        select: p

    result = Repo.all(query)
    IO.inspect(result)
    result
  end

  @doc """
  Create a new purchase_type
  """
  def new_purchase_type() do
    PurchaseType.new_changeset(%PurchaseType{}, %{})
  end

  def change_purchase_type(%PurchaseType{} = purchase_type, attrs \\ %{}) do
    PurchaseType.changeset(purchase_type, attrs)
  end

  def validate(%PurchaseType{} = purchase_type, attrs \\ %{}) do
    purchase_type
    |> change_purchase_type(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a purchase_type
  """
  def create_or_update_purchase_type(%PurchaseType{} = purchase_type, attrs \\ %{}) do
    purchase_type
    |> PurchaseType.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:purchase_types, :created_or_updated])
  end

  @doc """
  Delete a purchase type
  """
  def delete_purchase_type(%PurchaseType{} = purchase_type) do
    Repo.delete(purchase_type)
    |> notify_subscribers([:purchase_types, :deleted])
  end

  def notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, "#{@topic}:#{result.id}", {event, result})

    {:ok, result}
  end

  def notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
