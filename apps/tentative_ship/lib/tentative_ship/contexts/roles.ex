defmodule TentativeShip.Roles do
  import Ecto.Query

  alias TentativeShip.{
    Role,
    RolePermission,
    Repo,
    Yards
  }

  @topic "tentative_ship:authorization"

  def subscribe(), do: Phoenix.PubSub.subscribe(TentativeShip.PubSub, @topic)

  def subscribe(id), do: Phoenix.PubSub.subscribe(TentativeShip.PubSub, "#{@topic}:role:#{id}")

  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(TentativeShip.PubSub, @topic)

  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(TentativeShip.PubSub, "#{@topic}:role:#{id}")

  def new_role(), do: %Role{}

  def get_role!(id), do: Repo.get!(Role, id)

  def get_admin_role(), do: Repo.get_by(Role, name: "App Admin")

  def list_roles(yard_id, :include_app_admin) do
    Role
    |> where([r], r.yard_id == ^yard_id or r.app_admin)
    |> order_by([r], desc: r.app_admin, desc: r.yard_admin, asc: r.name)
    |> Repo.all()
  end

  def list_roles(:defaults) do
    Role
    |> where([r], r.default and is_nil(r.yard_id))
    |> order_by(desc: :default, asc: :name)
    |> Repo.all()
    |> Repo.preload(:permissions)
  end

  def list_roles(yard_id) do
    Role
    |> where([r], r.yard_id == ^yard_id)
    |> order_by(desc: :default, asc: :name)
    |> Repo.all()
    |> Repo.preload(:permissions)
  end

  def list_roles() do
    Role
    |> order_by(asc: :name)
    |> Repo.all()
    |> Repo.preload(:permissions)
  end

  def create_or_update_role(%Role{} = role, attrs \\ %{}) do
    {result, new_role} =
      role
      |> Role.changeset(attrs)
      |> Repo.insert_or_update()

    # create/update default role needs to update yard roles
    if result == :ok && new_role.default && is_nil(new_role.default_role_id) && !new_role.yard_admin do
      cond do
        Ecto.get_meta(role, :state) == :built -> # new default role
          curr_time =
            DateTime.utc_now()
            |> DateTime.truncate(:second)
            |> DateTime.to_naive()

          roles =
            Yards.list_yards()
            |> Enum.map(fn y -> %{
                name: "#{y.name} #{new_role.name}",
                default: new_role.default,
                description: new_role.description,
                yard_id: y.id,
                default_role_id: new_role.id,
                inserted_at: curr_time,
                updated_at: curr_time
              } end)
          Ecto.Multi.new()
          |> Ecto.Multi.insert_all(:insert_all, Role, roles)
          |> Repo.transaction()
        true -> # update default role
          Role
          |> where([r], r.default_role_id == ^new_role.id)
          |> Repo.all()
          |> Repo.preload(:yard)
          |> Enum.reduce(Ecto.Multi.new(), fn r, multi ->
              params = Map.replace(attrs, "name", "#{r.yard.name} #{new_role.name}")
              Ecto.Multi.update(multi, {:role, r.id}, Role.changeset(r, params))
            end)
          |> Repo.transaction()
      end
    end

    notify_subscribers({result, new_role}, [:role, (if Ecto.get_meta(role, :state) == :built, do: :created, else: :updated)])
  end

  def delete_role(%Role{} = role) do
    Repo.delete(role)
    |> notify_subscribers([:role, :deleted])
  end

  def change_role(%Role{} = role, attrs \\ %{}) do
    Role.changeset(role, attrs)
  end

  # Add a permission to a role if the role does not have it or
  # delete a permission from a role if it exists.
  def change_permission(role_id, permission_id) do
    parent_role = get_role!(role_id)
    role_permission =
      Repo.get_by(RolePermission, [role_id: role_id, permission_id: permission_id])

    roles =
      Role
      |> where([r], r.default_role_id == ^role_id)
      |> Repo.all()

    roles = [parent_role | roles]

    roles_ids = Enum.map(roles, &(&1.id))

    p_id = String.to_integer(permission_id)

    {result, _} = cond do
      role_permission ->
        query = from(r in RolePermission, where: r.permission_id == ^p_id and r.role_id in ^roles_ids)
        Ecto.Multi.new()
        |> Ecto.Multi.delete_all(:delete_all, query)
        |> Repo.transaction()
      true ->
        roles = Enum.map(roles_ids, &(%{role_id: &1, permission_id: p_id}))
        Ecto.Multi.new()
        |> Ecto.Multi.insert_all(:insert_all, RolePermission, roles)
        |> Repo.transaction()
    end

    roles
    |> Repo.preload(:permissions)
    |> Enum.each(&notify_subscribers({result, &1}, [:role, :updated]))
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(TentativeShip.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(TentativeShip.PubSub, "#{@topic}:role:#{result.id}", {event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
