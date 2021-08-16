defmodule TentativeShip.Shipments do
  import Ecto.Query

  alias TentativeShip.{
    Shipment,
    Repo
  }

  @topic "tentative_ship:shipments"

  def subscribe(), do: Phoenix.PubSub.subscribe(TentativeShip.PubSub, @topic)

  def subscribe(id), do: Phoenix.PubSub.subscribe(TentativeShip.PubSub, "#{@topic}:#{id}")

  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(TentativeShip.PubSub, @topic)

  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(TentativeShip.PubSub, "#{@topic}:#{id}")

  def new_shipment(), do: %Shipment{}

  def get_shipment!(id), do: Repo.get!(Shipment, id)

  def list_shipments(yard_id) do
    Shipment
    |> where([sc], sc.yard_id == ^yard_id)
    |> order_by(asc: :name)
    |> Repo.all()
  end

  def create_or_update_shipment(%Shipment{} = shipment, attrs \\ %{}) do
    shipment
    |> Shipment.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:shipment, (if Ecto.get_meta(shipment, :state) == :built, do: :created, else: :updated)])
  end

  def delete_shipment(%Shipment{} = shipment) do
    Repo.delete(shipment)
    |> notify_subscribers([:shipment, :deleted])
  end

  def change_shipment(%Shipment{} = shipment, attrs \\ %{}) do
    Shipment.changeset(shipment, attrs)
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(TentativeShip.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(TentativeShip.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
