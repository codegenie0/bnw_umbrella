defmodule CattlePurchase.PurchaseFlags do
  alias CattlePurchase.{
    PurchaseFlag,
    Repo
  }

  import Ecto.Query, only: [from: 2]
  @topic "cattle_purchase:purchase_flags"

  def subscribe(), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, @topic)
  def subscribe(id), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")
  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, @topic)
  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")

  @doc """
  List all purchase_flags
  """

  def list_purchase_flags() do
    Repo.all(PurchaseFlag)
  end

  @doc """
  Create a new purchase_flag
  """
  def new_purchase_flag() do
    PurchaseFlag.new_changeset(%PurchaseFlag{}, %{})
  end

  def change_purchase_flag(%PurchaseFlag{} = purchase_flag, attrs \\ %{}) do
    PurchaseFlag.changeset(purchase_flag, attrs)
  end

  def validate(%PurchaseFlag{} = purchase_flag, attrs \\ %{}) do
    purchase_flag
    |> change_purchase_flag(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a purchase_flag
  """
  def create_or_update_purchase_flag(%PurchaseFlag{} = purchase_flag, attrs \\ %{}) do
    purchase_flag
    |> PurchaseFlag.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:purchase_flags, :created_or_updated])
  end

  @doc """
  Delete a purchase type
  """
  def delete_purchase_flag(%PurchaseFlag{} = purchase_flag) do
    Repo.delete(purchase_flag)
    |> notify_subscribers([:purchase_flags, :deleted])
  end

  def notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, "#{@topic}:#{result.id}", {event, result})

    {:ok, result}
  end

  def notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
