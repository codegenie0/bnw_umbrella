defmodule Reimbursement.Users do
  import Ecto.Query

  alias Reimbursement.{
    Repo,
    User,
    UserRole
  }

  @topic "accounts:users"

  @doc """
  This function subscribes a user to changes in the reimbursement entries page.
  This allows for users to get a live update on their role within the application.
  """
  def subscribe(), do: Phoenix.PubSub.subscribe(Accounts.PubSub, @topic)
  def subscribe(id), do: Phoenix.PubSub.subscribe(Accounts.PubSub, "#{@topic}:#{id}")

  @doc """
  This function unsubscribes a user to changes in the reimbursement entries page.
  """
  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(Accounts.PubSub, @topic)
  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(Accounts.PubSub, "#{@topic}:#{id}")

  @doc """
  create a new user for this application
  """
  def new_user(), do: %User{}

  @doc """
  get a user by id
  """
  def get_user(id) do
    User
    |> Repo.get(id)
    |> Repo.preload(:users_roles)
  end

  @doc """
  get a user by id force
  """
  def get_user!(id) do
    User
    |> Repo.get!(id)
    |> Repo.preload(:users_roles)
  end

  @doc """
  list active users
  select all users with the role active
  """
  def list_active_users(current_page \\ 1, per_page \\ 10, search \\ "") do
    search = "%#{search}%"
    User
    |> join(:left, [user], user_roles in UserRole, on: user.id == user_roles.user_id and user_roles.role == "active")
    |> preload([user, user_roles], [:users_roles])
    |> where([user, user_roles], not user.customer and user.active and not is_nil(user_roles.user_id) and
      (like(user.username, ^search) or
       like(user.name, ^search) or
       like(user.email, ^search)))
    |> group_by([user, user_roles], user.id)
    |> order_by([user, user_roles], user.username)
    |> offset(^(per_page * (current_page - 1)))
    |> limit(^per_page)
    |> Repo.all()
  end

  @doc """
  list all users
  """
  def list_all_users(current_page \\ 1, per_page \\ 10, search \\ "") do
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

  @doc """
  list all users for a reviewer
  this shows all the users that the reviewer is reviewing
  """
  def list_reviewers_users(current_user, search \\ "") do
    search = "%#{search}%"
    User
    |> join(:left, [user], user_roles in UserRole, on: user.id == user_roles.user_id)
    |> preload([user, user_roles], [:users_roles])
    |> where([user, user_roles],
      not user.customer
      and user.active
      and user_roles.reviewer_id == ^current_user
      and (like(user.username, ^search) or
           like(user.name, ^search) or
           like(user.email, ^search)))
    |> group_by([user, user_roles], user.id)
    |> order_by([user, user_roles], user.username)
    |> Repo.all()
  end

  @doc """
  count the total number of pages of active users
  """
  def total_active_pages(per_page \\ 10, search \\ "") do
    search = "%#{search}%"
    user_count = User
    |> join(:left, [user], user_roles in UserRole, on: user.id == user_roles.user_id)
    |> preload([user, user_roles], [:users_roles])
    |> where([user, user_roles], not user.customer and user.active and user_roles.role == "active" and
    (like(user.username, ^search) or
      like(user.name, ^search) or
      like(user.email, ^search)))
      |> Repo.aggregate(:count, :id)

    (user_count / per_page)
    |> Decimal.from_float()
    |> Decimal.round(0, :up)
    |> Decimal.to_integer()
  end

  @doc """
  count the total number of pages of users
  """
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

  def notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(Accounts.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(Accounts.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end

  def notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
