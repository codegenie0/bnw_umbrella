defmodule TentativeShip.SexCodes do
  import Ecto.Query

  alias TentativeShip.{
    SexCode,
    Repo
  }

  @topic "tentative_ship:sex_codes"

  def subscribe(), do: Phoenix.PubSub.subscribe(TentativeShip.PubSub, @topic)

  def subscribe(id), do: Phoenix.PubSub.subscribe(TentativeShip.PubSub, "#{@topic}:#{id}")

  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(TentativeShip.PubSub, @topic)

  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(TentativeShip.PubSub, "#{@topic}:#{id}")

  def new_sex_code(), do: %SexCode{}

  def get_sex_code!(id), do: Repo.get!(SexCode, id)

  def list_sex_codes(yard_id) do
    SexCode
    |> where([sc], sc.yard_id == ^yard_id)
    |> order_by(asc: :name)
    |> Repo.all()
  end

  def create_or_update_sex_code(%SexCode{} = sex_code, attrs \\ %{}) do
    sex_code
    |> SexCode.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:sex_code, (if Ecto.get_meta(sex_code, :state) == :built, do: :created, else: :updated)])
  end

  def delete_sex_code(%SexCode{} = sex_code) do
    Repo.delete(sex_code)
    |> notify_subscribers([:sex_code, :deleted])
  end

  def change_sex_code(%SexCode{} = sex_code, attrs \\ %{}) do
    SexCode.changeset(sex_code, attrs)
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(TentativeShip.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(TentativeShip.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
