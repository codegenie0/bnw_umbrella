defmodule BorrowingBase.Roles do
  import Ecto.Query

  alias BorrowingBase.{
    Role,
    Repo,
    Yard
  }

  @topic "borrowing_base:role"

  def subscribe(), do: Phoenix.PubSub.subscribe(BorrowingBase.PubSub, @topic)

  def subscribe(id), do: Phoenix.PubSub.subscribe(BorrowingBase.PubSub, "#{@topic}:#{id}")

  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(BorrowingBase.PubSub, @topic)

  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(BorrowingBase.PubSub, "#{@topic}:#{id}")

  def new_role(), do: %Role{}

  def get_role!(id), do: Repo.get!(Role, id)

  def list_roles(company_id, :include_app_admin) do
    Role
    |> where([r], r.company_id == ^company_id or r.app_admin)
    |> order_by([r], desc: r.app_admin, desc: r.company_admin, asc: r.name)
    |> Repo.all()
  end

  def list_roles(company_id) do
    Role
    |> where([r], r.company_id == ^company_id)
    |> order_by(asc: :name)
    |> Repo.all()
  end

  def list_roles() do
    Role
    |> order_by(asc: :name)
    |> Repo.all()
  end

  def list_yards(%Role{} = role) do
    Yard
    |> join(:left, [y], ry in "roles_yards", on: y.id == ry.yard_id and ry.role_id == ^role.id)
    |> where([y, ry], y.company_id == ^role.company_id)
    |> order_by([y, ry], asc: y.name)
    |> select([y, ry], %{id: y.id, name: y.name, checked: not is_nil(ry.id)})
    |> Repo.all()
  end

  def create_or_update_role(%Role{} = role, attrs \\ %{}) do
    role
    |> Role.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:role, :updated])
  end

  def delete_role(%Role{} = role) do
    Repo.delete(role)
    |> notify_subscribers([:role, :deleted])
  end

  def change_role(%Role{} = role, attrs \\ %{}) do
    Role.changeset(role, attrs)
  end

  def add_yard(%Role{} = role, yard_id) do
    query =
      from(ry in "roles_yards")
      |> where([ry], ry.role_id == ^role.id and ry.yard_id == ^yard_id)
    ry =
      query
      |> select([ry], %{id: ry.id})
      |> Repo.all()

    cond do
      !Enum.empty?(ry) ->
        Repo.delete_all(query)
      true ->
        Repo.insert_all("roles_yards", [%{role_id: role.id, yard_id: yard_id}])
    end
    notify_subscribers({:ok, role}, [:role, :updated])
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(BorrowingBase.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(BorrowingBase.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
