defmodule BorrowingBase.Yards do
  import Ecto.Query

  alias BorrowingBase.{
    Yard,
    Repo
  }

  @topic "borrowing_base:yard"

  def subscribe(), do: Phoenix.PubSub.subscribe(BorrowingBase.PubSub, @topic)

  def subscribe(id), do: Phoenix.PubSub.subscribe(BorrowingBase.PubSub, "#{@topic}:#{id}")

  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(BorrowingBase.PubSub, @topic)

  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(BorrowingBase.PubSub, "#{@topic}:#{id}")

  def new_yard(), do: %Yard{}

  def get_yard!(id), do: Repo.get!(Yard, id)

  def list_yards(company_id, user_id) do
    Yard
    |> join(:inner, [y], ry in "roles_yards", on: y.id == ry.yard_id)
    |> join(:inner, [y, ry], ur in "users_roles", on: ry.role_id == ur.role_id)
    |> select([y, ry, ur], y)
    |> where([y, ry, ur], ur.user_id == ^user_id and y.company_id == ^company_id)
    |> group_by([y, ry, ur], y.id)
    |> order_by(asc: :name)
    |> Repo.all()
  end

  def list_yards(company_id) do
    Yard
    |> where([y], y.company_id == ^company_id)
    |> order_by(asc: :name)
    |> Repo.all()
  end

  def list_yards() do
    Yard
    |> order_by(asc: :name)
    |> Repo.all()
  end

  def create_or_update_yard(%Yard{} = yard, attrs \\ %{}) do
    yard
    |> Yard.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:yard, :updated])
  end

  def delete_yard(%Yard{} = yard) do
    Repo.delete(yard)
    |> notify_subscribers([:yard, :deleted])
  end

  def change_yard(%Yard{} = yard, attrs \\ %{}) do
    Yard.changeset(yard, attrs)
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(BorrowingBase.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(BorrowingBase.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
