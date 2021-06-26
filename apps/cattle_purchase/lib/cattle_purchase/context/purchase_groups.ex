defmodule CattlePurchase.PurchaseGroups do
  alias CattlePurchase.{
    PurchaseGroup,
    Repo
  }

  import Ecto.Query, only: [from: 2]
  @topic "cattle_purchase:purchase_groups"

  def subscribe(), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, @topic)
  def subscribe(id), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")
  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, @topic)
  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")

  @doc """
  List all purchase_groups
  """

  def list_purchase_groups() do
    Repo.all(PurchaseGroup)
  end

  @doc """
  Create a new purchase_group
  """
  def new_purchase_group() do
    PurchaseGroup.new_changeset(%PurchaseGroup{}, %{})
  end

  def change_purchase_group(%PurchaseGroup{} = purchase_group, attrs \\ %{}) do
    PurchaseGroup.changeset(purchase_group, attrs)
  end

  def validate(%PurchaseGroup{} = purchase_group, attrs \\ %{}) do
    purchase_group
    |> change_purchase_group(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a purchase_group
  """
  def create_or_update_purchase_group(%PurchaseGroup{} = purchase_group, attrs \\ %{}) do
    purchase_group
    |> PurchaseGroup.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:purchase_groups, :created_or_updated])
  end

  @doc """
  Delete a purchase type
  """
  def delete_purchase_group(%PurchaseGroup{} = purchase_group) do
    Repo.delete(purchase_group)
    |> notify_subscribers([:purchase_groups, :deleted])
  end

  def notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, "#{@topic}:#{result.id}", {event, result})

    {:ok, result}
  end

  def notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
