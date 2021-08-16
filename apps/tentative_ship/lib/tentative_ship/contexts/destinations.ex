defmodule TentativeShip.Destinations do
  import Ecto.Query

  alias TentativeShip.{
    Destination,
    Repo
  }

  @topic "tentative_ship:destinations"

  def subscribe(), do: Phoenix.PubSub.subscribe(TentativeShip.PubSub, @topic)

  def subscribe(id), do: Phoenix.PubSub.subscribe(TentativeShip.PubSub, "#{@topic}:#{id}")

  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(TentativeShip.PubSub, @topic)

  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(TentativeShip.PubSub, "#{@topic}:#{id}")

  def new_destination(), do: %Destination{}

  def get_destination!(id), do: Repo.get!(Destination, id)

  def list_destinations(yard_id) do
    Destination
    |> where([sc], sc.yard_id == ^yard_id)
    |> order_by(asc: :name)
    |> Repo.all()
  end

  def create_or_update_destination(%Destination{} = destination, attrs \\ %{}) do
    destination
    |> Destination.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:destination, (if Ecto.get_meta(destination, :state) == :built, do: :created, else: :updated)])
  end

  def delete_destination(%Destination{} = destination) do
    Repo.delete(destination)
    |> notify_subscribers([:destination, :deleted])
  end

  def change_destination(%Destination{} = destination, attrs \\ %{}) do
    Destination.changeset(destination, attrs)
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(TentativeShip.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(TentativeShip.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
