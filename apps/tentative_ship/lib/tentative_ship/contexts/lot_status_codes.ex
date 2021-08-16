defmodule TentativeShip.LotStatusCodes do
  import Ecto.Query

  alias TentativeShip.{
    LotStatusCode,
    Repo
  }

  @topic "tentative_ship:lot_status_codes"

  def subscribe(), do: Phoenix.PubSub.subscribe(TentativeShip.PubSub, @topic)

  def subscribe(id), do: Phoenix.PubSub.subscribe(TentativeShip.PubSub, "#{@topic}:#{id}")

  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(TentativeShip.PubSub, @topic)

  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(TentativeShip.PubSub, "#{@topic}:#{id}")

  def new_lot_status_code(), do: %LotStatusCode{}

  def get_lot_status_code!(id), do: Repo.get!(LotStatusCode, id)

  def list_lot_status_codes(yard_id) do
    LotStatusCode
    |> where([lsc], lsc.yard_id == ^yard_id)
    |> order_by(asc: :name)
    |> Repo.all()
  end

  def create_or_update_lot_status_code(%LotStatusCode{} = lot_status_code, attrs \\ %{}) do
    lot_status_code
    |> LotStatusCode.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:lot_status_code, (if Ecto.get_meta(lot_status_code, :state) == :built, do: :created, else: :updated)])
  end

  def delete_lot_status_code(%LotStatusCode{} = lot_status_code) do
    Repo.delete(lot_status_code)
    |> notify_subscribers([:lot_status_code, :deleted])
  end

  def change_lot_status_code(%LotStatusCode{} = lot_status_code, attrs \\ %{}) do
    LotStatusCode.changeset(lot_status_code, attrs)
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(TentativeShip.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(TentativeShip.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
