defmodule CattlePurchase.CattleReceivings do
  alias CattlePurchase.{
    CattleReceiving,
    Repo
  }

  import Ecto.Query, only: [from: 2]
  @topic "cattle_purchase:cattle_receivings"

  def subscribe(), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, @topic)
  def subscribe(id), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")
  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, @topic)
  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")

  @doc """
  List all cattle_receivings tied to a particular shipment
  """
  def get_cattle_receivings(shipment_id) do
    from(s in CattleReceiving,
      where: s.shipment_id == ^shipment_id
    )
    |> Repo.all()
    |> Repo.preload([:user, :sex])
  end

  @doc """
  Create a new cattle_receiving
  """
  def new_cattle_receiving() do
    CattleReceiving.new_changeset(%CattleReceiving{}, %{})
  end

  def change_cattle_receiving(%CattleReceiving{} = cattle_receiving, attrs \\ %{}) do
    CattleReceiving.changeset(cattle_receiving, attrs)
  end

  def validate(%CattleReceiving{} = cattle_receiving, attrs \\ %{}) do
    cattle_receiving
    |> change_cattle_receiving(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a cattle_receiving
  """
  def create_or_update_cattle_receiving(%CattleReceiving{} = cattle_receiving, attrs \\ %{}) do
    cattle_receiving
    |> CattleReceiving.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:cattle_receivings, :created_or_updated])
  end

  @doc """
  Delete a cattle_receiving
  """
  def delete_cattle_receiving(%CattleReceiving{} = cattle_receiving) do
    Repo.delete(cattle_receiving)
    |> notify_subscribers([:cattle_receivings, :deleted])
  end

  def notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, "#{@topic}:#{result.id}", {event, result})

    {:ok, result}
  end

  def notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
