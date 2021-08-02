defmodule CattlePurchase.Shipments do
  alias CattlePurchase.{
    Shipment,
    Repo
  }

  import Ecto.Query, only: [from: 2]
  @topic "cattle_purchase:shipments"

  def subscribe(), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, @topic)
  def subscribe(id), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")
  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, @topic)
  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")

  @doc """
  List all shipments tied to a particular purchase
  """
  def get_shipments(purchase_id) do
    from(s in Shipment,
      where: s.purchase_id == ^purchase_id
    )
    |> Repo.all()
  end

  @doc """
  Create a new shipment
  """
  def new_shipment() do
    Shipment.new_changeset(%Shipment{}, %{})
  end

  def change_shipment(%Shipment{} = shipment, attrs \\ %{}) do
    Shipment.changeset(shipment, attrs)
  end

  def validate(%Shipment{} = shipment, attrs \\ %{}) do
    shipment
    |> change_shipment(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a shipment
  """
  def create_or_update_shipment(%Shipment{} = shipment, attrs \\ %{}) do
    shipment
    |> Shipment.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:shipments, :created_or_updated])
  end

  @doc """
  Delete a shipment
  """
  def delete_shipment(%Shipment{} = shipment) do
    Repo.delete(shipment)
    |> notify_subscribers([:shipments, :deleted])
  end

  def notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, "#{@topic}:#{result.id}", {event, result})

    {:ok, result}
  end

  def notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
