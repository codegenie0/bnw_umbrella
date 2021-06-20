defmodule Accounts.Users do
  import Ecto.Query
  import Ecto.Changeset

  alias Accounts.{
    User,
    Repo
  }

  @topic "accounts:users"

  def subscribe(), do: Phoenix.PubSub.subscribe(Accounts.PubSub, @topic)

  def subscribe(id), do: Phoenix.PubSub.subscribe(Accounts.PubSub, "#{@topic}:#{id}")

  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(Accounts.PubSub, @topic)

  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(Accounts.PubSub, "#{@topic}:#{id}")

  def new_user(), do: %User{}

  def get_user(id), do: Repo.get(User, id)

  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by(var, val) do
    Repo.get_by(User, [{var, val}])
  end

  def list_users(include_customers \\ false, current_page \\ 1, per_page \\ 10, search \\ "") do
    search = "%#{search}%"
    query = cond do
      include_customers ->
        where(User, [user],
          (like(user.username, ^search) or
           like(user.name, ^search) or
           like(user.email, ^search)))
      true ->
        where(User, [user], not user.customer and
          (like(user.username, ^search) or
           like(user.name, ^search) or
           like(user.email, ^search)))
    end

    query
    |> order_by([user], user.username)
    |> offset(^(per_page * (current_page - 1)))
    |> limit(^per_page)
    |> Repo.all()
  end

  def total_pages(include_customers \\ false, per_page \\ 10, search \\ "") do
    search = "%#{search}%"
    query = cond do
      include_customers ->
        where(User, [user],
          (like(user.username, ^search) or
           like(user.name, ^search) or
           like(user.email, ^search)))
      true ->
        where(User, [user], not user.customer and
          (like(user.username, ^search) or
           like(user.name, ^search) or
           like(user.email, ^search)))
    end

    user_count = Repo.aggregate(query, :count, :id)

    (user_count / per_page)
    |> Decimal.from_float()
    |> Decimal.round(0, :up)
    |> Decimal.to_integer()
  end

  def create_or_update_user(%User{} = user, attrs \\ %{}) do
    changeset = User.changeset(user, attrs)
    {_, email} = fetch_field(changeset, :email)
    cond do
      is_nil(email) || email == "" ->
        force_change(changeset, :allow_password_reset, false)
      true ->
        changeset
    end
    |> Repo.insert_or_update()
    |> notify_subscribers([:user, (if Ecto.get_meta(user, :state) == :built, do: :created, else: :updated)])
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
    |> notify_subscribers([:user, :deleted])
  end

  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(Accounts.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(Accounts.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
