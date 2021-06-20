defmodule Reimbursement.UserRoles do
  import Ecto.Query

  alias Reimbursement.{
    Repo,
    UserRole,
    Users,
    User
  }


  @topic "Reimbursement:user_roles"

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
  get the current users roles
  """
  def get_user_roles(id) do
    %{users_roles: user_role} = Users.get_user(id)
    Repo.preload(user_role, :user)
    user_role
  end

  @doc """
  get the current users roles forced
  """
  def get_user_roles!(id) do
    %{user_roles: user_role} = Users.get_user(id)
    user_role
  end

  @doc """
  check who the users reviewer is
  """
  def get_reviewer(id) do
    User
      |> join(:left, [user], user_roles in UserRole, on: user.id == user_roles.reviewer_id)
      |> join(:left, [user], user_roles_2 in UserRole, on: user.id == user_roles_2.user_id)
      |> where([user, user_roles, user_roles_2], not user.customer and user.active and user_roles.user_id == ^id and user_roles.role == "none" and user_roles_2.role == "active")
      |> group_by([user, user_roles], user.id)
      |> order_by([user, user_roles], user.name)
      |> Repo.one()
  end

  @doc """
  list all reviewers
  """
  def list_reviewers() do
    User
      |> join(:left, [user], user_roles in UserRole, on: user.id == user_roles.user_id)
      |> join(:left, [user], user_roles_2 in UserRole, on: user.id == user_roles_2.user_id)
      |> preload([user, user_roles], [:users_roles])
      |> where([user, user_roles, user_roles_2], not user.customer and user.active and user_roles.role == "reviewer" and user_roles_2.role == "active")
      |> group_by([user, user_roles], user.id)
      |> order_by([user, user_roles], user.name)
      |> Repo.all()
  end

  @doc """
  set a users reviewer

  # get the previous reviewer
  # note that role = none has the reviewer

  # delete the previous reviewer entry

  # insert the new reviewer
  """
  def set_reviewer(user_id, reviewer_id) do
    # get the previous reviewer
    # note that role = none has the reviewer
    user_role =
      UserRole
      |> where([ur], ur.user_id == ^user_id and ur.role == ^"none")
      |> Repo.one()

    # delete the previous reviewer entry
    if user_role do
      Repo.delete(user_role)
    end

    # insert the new reviewer
    Repo.insert(%UserRole{user_id: String.to_integer(user_id), role: "none", reviewer_id: String.to_integer(reviewer_id)})
    |> notify_subscribers([:user, :updated])
  end

  def get_a_role(user_id, role) do
    role = UserRole
    |> where([ur], ur.user_id == ^user_id and ur.role == ^role)
    |> select([ur], [ur.role])
    |> limit(1)
    |> Repo.one()

    cond do
      is_nil(role) -> false
      true -> true
    end
  end

  def get_role(user_id) do
    active =
      UserRole
      |> where([ur], ur.user_id == ^user_id and ur.role == "active")
      |> select([ur], [ur.role])
      |> limit(1)
      |> Repo.one()
    if !is_nil(active) && Enum.at(active, 0) == "active" do
      role =
        UserRole
        |> where([ur], ur.user_id == ^user_id)
        |> select([ur], [ur.role])
        |> order_by([ur], desc: fragment("field(?, 'none', 'user', 'report', 'reviewer', 'admin')", ur.role))
        |> limit(1)
        |> Repo.one()

      cond do
        role -> Enum.at(role, 0)
        true -> nil
      end
    else
      nil
    end
  end

  @doc """
  set the users role

  # check if that role exists

  # if a reviewer role is being updated
  # set all reviewer's children's reviewer to null

  # set the new role
  """
  def set_role(user_id, role) do
    # check if that role exists
    user_role =
      UserRole
      |> where([ur], ur.user_id == ^user_id and ur.role == ^role)
      |> Repo.one()

    # if a reviewer role is being updated
    # set all reviewer's children's reviewer to null
    if role == "reviewer" do
      reviewies =
        UserRole
        |> where([ur], ur.reviewer_id == ^user_id)
        |> Repo.all()

      if reviewies do
        Enum.map(reviewies, fn r -> Repo.delete(r) end)
      end
    end

    # set the new role
    cond do
      user_role -> Repo.delete(user_role)
      true -> Repo.insert(%UserRole{user_id: String.to_integer(user_id), role: role})
    end
    |> Users.notify_subscribers([:user, :updated])
  end

  @doc """
  Get a changeset for user role
  """
  def change_user_role(%UserRole{} = user_role, attrs \\ %{}) do
    UserRole.changeset(user_role, attrs)
  end

  # Tell everyone who is subscribed about a change.
  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(Accounts.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(Accounts.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
