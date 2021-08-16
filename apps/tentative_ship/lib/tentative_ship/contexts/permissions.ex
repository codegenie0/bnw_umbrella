defmodule TentativeShip.Permissions do
  import Ecto.Query

  alias TentativeShip.{
    Permission,
    Repo
  }

  @topic "tentative_ship:authorization"

  def subscribe(), do: Phoenix.PubSub.subscribe(TentativeShip.PubSub, @topic)

  def subscribe(id), do: Phoenix.PubSub.subscribe(TentativeShip.PubSub, "#{@topic}:permission:#{id}")

  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(TentativeShip.PubSub, @topic)

  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(TentativeShip.PubSub, "#{@topic}:permission:#{id}")

  def new_permission(), do: %Permission{}

  def get_permission!(id), do: Repo.get!(Permission, id)

  def list_permissions() do
    Permission
    |> order_by(asc: :name)
    |> Repo.all()
  end

  def create_or_update_permission(%Permission{} = permission, attrs \\ %{}) do
    permission
    |> Permission.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:permission, (if Ecto.get_meta(permission, :state) == :built, do: :created, else: :updated)])
  end

  def delete_permission(%Permission{} = permission) do
    Repo.delete(permission)
    |> notify_subscribers([:permission, :deleted])
  end

  def change_permission(%Permission{} = permission, attrs \\ %{}) do
    Permission.changeset(permission, attrs)
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(TentativeShip.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(TentativeShip.PubSub, "#{@topic}:permission:#{result.id}", {event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
