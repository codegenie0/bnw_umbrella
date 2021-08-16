defmodule TentativeShip.Users do
  import Ecto.Query

  alias TentativeShip.{
    Repo,
    Role,
    User,
    UserRole
  }

  @topic "accounts:users"

  def subscribe(), do: Phoenix.PubSub.subscribe(Accounts.PubSub, @topic)

  def subscribe(id), do: Phoenix.PubSub.subscribe(Accounts.PubSub, "#{@topic}:#{id}")

  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(Accounts.PubSub, @topic)

  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(Accounts.PubSub, "#{@topic}:#{id}")

  def get_user!(id), do: Repo.get!(User, id)

  def list_users(current_page \\ 1, per_page \\ 10, search \\ "") do
    search = "%#{search}%"
    User
    |> where([user], not user.customer and
                                 user.active and
                                 (like(user.username, ^search) or
                                 like(user.name, ^search) or
                                 like(user.email, ^search)))
    |> group_by([user], user.id)
    |> order_by([user], user.username)
    |> offset(^(per_page * (current_page - 1)))
    |> limit(^per_page)
    |> Repo.all()
    |> Repo.preload(:roles)
  end

  def total_pages(per_page \\ 10, search \\ "") do
    search = "%#{search}%"
    user_count =
      User
      |> where([user], not user.customer and
                       user.active and
                       (like(user.username, ^search) or
                       like(user.name, ^search) or
                       like(user.email, ^search)))
      |> Repo.aggregate(:count, :id)

    (user_count / per_page)
    |> Decimal.from_float()
    |> Decimal.round(0, :up)
    |> Decimal.to_integer()
  end

  def list_roles(user_id) do
    UserRole
    |> join(:left, [ur], r in Role, on: ur.role_id == r.id)
    |> where([ur, r], ur.user_id == ^user_id)
    |> select([ur, r], r)
    |> Repo.all()
  end

  def change_role(user_id, role_id) do
    user_role = Repo.get_by(UserRole, [user_id: user_id, role_id: role_id])

    {result, _} =
      cond do
        user_role -> Repo.delete(user_role)
        true -> Repo.insert(%UserRole{user_id: user_id, role_id: role_id})
      end

    user =
      user_id
      |> get_user!()
      |> Repo.preload(:roles)

    notify_subscribers({result, user}, [:user, :role_updated])
  end

  def set_app_admin(user_id) do
    admin_role = Repo.get_by(Role, app_admin: true)
    user_role = Repo.get_by(UserRole, [user_id: user_id, role_id: admin_role.id])

    cond do
      user_role -> Repo.delete(user_role)
      true -> Repo.insert(%UserRole{user_id: user_id, role_id: admin_role.id})
    end
    |> notify_subscribers([:tentative_ship, :set_app_admin])
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(Accounts.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(Accounts.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
