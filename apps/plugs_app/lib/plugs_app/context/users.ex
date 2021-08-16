defmodule PlugsApp.Users do
  import Ecto.Query

  alias PlugsApp.{
    Repo,
    Roles,
    User,
    UserRole
  }

  @topic "accounts:users"

  def subscribe(), do: Phoenix.PubSub.subscribe(Accounts.PubSub, @topic)

  def subscribe(id), do: Phoenix.PubSub.subscribe(Accounts.PubSub, "#{@topic}:#{id}")

  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(Accounts.PubSub, @topic)

  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(Accounts.PubSub, "#{@topic}:#{id}")

  def new_user(), do: %User{}

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

  def get_users_rolls(user_id) do
    UserRole
    |> where([user_role], user_role.user_id == ^user_id)
    |> Repo.all()
    |> Enum.map(fn x->
      %{role: role, level: level} = x
      %{role: role, level: level}
    end)
  end

  def has_roll(user_id, roll) do
    role =
      UserRole
      |> where([user_role], user_role.user_id == ^user_id and user_role.role == ^roll)
      |> Repo.one()
    if is_nil(role) do
      {false, 0}
    else
      %{level: level} = role
      {true, level}
    end
  end

  def list_secondary_roles(user_id) do
    {admin, _} = has_roll(user_id, "admin")
    if admin do
      Roles.list_secondary_roles()
    else
      admin_roles = UserRole
        |> where([user_role], user_role.user_id == ^user_id and user_role.level == ^"admin")
        |> Repo.all()
      Roles.list_secondary_roles()
        |> Enum.filter(fn x ->
          %{name: name} = x
          Enum.any?(admin_roles, fn y ->
            %{role: role} = y
            name == role
          end)
        end)
    end
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

  def change_role(user_id, role, level \\ "") do
    user_role =
      UserRole
      |> where([ur], ur.user_id == ^user_id and ur.role == ^role)
      |> Repo.one()

    cond do
      level == "" ->
        if user_role, do: Repo.delete(user_role)
      true ->
        if user_role, do: Repo.delete(user_role)
        Repo.insert(%UserRole{user_id: String.to_integer(user_id), role: role, level: level})
    end
    |> notify_subscribers([:user, :updated])
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(Accounts.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(Accounts.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
