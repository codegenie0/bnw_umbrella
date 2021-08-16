defmodule TentativeShip.YardNumbers do
  import Ecto.Query

  alias TentativeShip.{
    YardNumber,
    Repo
  }

  @topic "tentative_ship:yard_numbers"

  def subscribe(), do: Phoenix.PubSub.subscribe(TentativeShip.PubSub, @topic)

  def subscribe(id), do: Phoenix.PubSub.subscribe(TentativeShip.PubSub, "#{@topic}:#{id}")

  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(TentativeShip.PubSub, @topic)

  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(TentativeShip.PubSub, "#{@topic}:#{id}")

  def new_yard_number(), do: %YardNumber{}

  def get_yard_number!(id), do: Repo.get!(YardNumber, id)

  def list_yard_numbers(yard_id) do
    YardNumber
    |> where([sc], sc.yard_id == ^yard_id)
    |> order_by(asc: :name)
    |> Repo.all()
  end

  def create_or_update_yard_number(%YardNumber{} = yard_number, attrs \\ %{}) do
    yard_number
    |> YardNumber.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:yard_number, (if Ecto.get_meta(yard_number, :state) == :built, do: :created, else: :updated)])
  end

  def delete_yard_number(%YardNumber{} = yard_number) do
    Repo.delete(yard_number)
    |> notify_subscribers([:yard_number, :deleted])
  end

  def change_yard_number(%YardNumber{} = yard_number, attrs \\ %{}) do
    YardNumber.changeset(yard_number, attrs)
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(TentativeShip.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(TentativeShip.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
