defmodule CattlePurchase.Commissions do
  alias CattlePurchase.{
    Commission,
    Repo
  }

  import Ecto.Query, only: [from: 2]
  @topic "cattle_purchase:commissions"

  def subscribe(), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, @topic)
  def subscribe(id), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")
  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, @topic)
  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")

  @doc """
  List all commissions
  """

  @doc """
  Create a new commission
  """
  def new_commission() do
    Commission.new_changeset(%Commission{}, %{})
  end

  def change_commission(%Commission{} = commission, attrs \\ %{}) do
    Commission.changeset(commission, attrs)
  end

  def validate(%Commission{} = commission, attrs \\ %{}) do
    commission
    |> change_commission(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a commission
  """
  def create_or_update_commission(%Commission{} = commission, attrs \\ %{}) do
    commission
    |> Commission.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:commissions, :created_or_updated])
  end

  @doc """
  Delete a purchase type
  """
  def delete_commission(%Commission{} = commission) do
    Repo.delete(commission)
    |> notify_subscribers([:commissions, :deleted])
  end

  def notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, "#{@topic}:#{result.id}", {event, result})

    {:ok, result}
  end

  def notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
