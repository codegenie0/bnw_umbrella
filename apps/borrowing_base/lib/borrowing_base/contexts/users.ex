defmodule BorrowingBase.Users do
  import Ecto.Query

  alias BorrowingBase.{
    Repo,
    Role,
    Roles,
    User,
    UserRole
  }

  @topic "accounts:users"

  def subscribe(), do: Phoenix.PubSub.subscribe(Accounts.PubSub, @topic)

  def subscribe(id), do: Phoenix.PubSub.subscribe(Accounts.PubSub, "#{@topic}:#{id}")

  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(Accounts.PubSub, @topic)

  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(Accounts.PubSub, "#{@topic}:#{id}")

  def get_user(id) do
    User
    |> Repo.get(id)
    |> Repo.preload(:users_roles)
  end

  def get_user!(id) do
    User
    |> Repo.get!(id)
    |> Repo.preload(:users_roles)
  end

  def list_users(current_page \\ 1, per_page \\ 10, search \\ "") do
    search = "%#{search}%"
    User
    |> join(:left, [user], user_roles in UserRole, on: user.id == user_roles.user_id)
    |> preload([user, user_roles], [:users_roles])
    |> where([user, user_roles], not user.customer and user.active and
      (like(user.username, ^search) or
       like(user.name, ^search) or
       like(user.email, ^search)))
    |> group_by([user, user_roles], user.id)
    |> order_by([user, user_roles], user.username)
    |> offset(^(per_page * (current_page - 1)))
    |> limit(^per_page)
    |> Repo.all()
  end

  def total_pages(per_page \\ 10, search \\ "") do
    search = "%#{search}%"
    user_count = User
    |> where([user], not user.customer and user.active and
      (like(user.username, ^search) or
       like(user.name, ^search) or
       like(user.email, ^search)))
    |> Repo.aggregate(:count, :id)

    (user_count / per_page)
    |> Decimal.from_float()
    |> Decimal.round(0, :up)
    |> Decimal.to_integer()
  end

  def change_role(user_id, role_id) do
    user_id = String.to_integer(user_id)
    role_id = String.to_integer(role_id)
    role = Roles.get_role!(role_id)

    user_role =
      UserRole
      |> where([ur], ur.user_id == ^user_id and ur.role_id == ^role_id)
      |> Repo.one()

    cond do
      user_role -> Repo.delete(user_role)
      true -> Repo.insert(%UserRole{user_id: user_id, role_id: role_id})
    end

    user =
      user_id
      |> get_user!()
      |> Map.put(:company_id, role.company_id)

    notify_subscribers({:ok, user}, [:user, :updated])
  end

  def list_roles(user_id) do
    UserRole
    |> join(:left, [ur], r in Role, on: ur.role_id == r.id)
    |> where([ur, r], ur.user_id == ^user_id)
    |> select([ur, r], r)
    |> Repo.all()
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(Accounts.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(Accounts.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
