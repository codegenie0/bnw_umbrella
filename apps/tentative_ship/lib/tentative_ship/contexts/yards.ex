defmodule TentativeShip.Yards do
  import Ecto.Query

  alias TentativeShip.{
    Yard,
    Repo,
    Role,
    Roles
  }

  @topic "tentative_ship:yard"

  def subscribe(), do: Phoenix.PubSub.subscribe(TentativeShip.PubSub, @topic)

  def subscribe(id), do: Phoenix.PubSub.subscribe(TentativeShip.PubSub, "#{@topic}:#{id}")

  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(TentativeShip.PubSub, @topic)

  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(TentativeShip.PubSub, "#{@topic}:#{id}")

  def new_yard(), do: %Yard{}

  def get_yard!(id), do: Repo.get!(Yard, id)

  def list_yards() do
    Yard
    |> order_by([y], desc: fragment("field(?, 'all')", y.name))
    |> Repo.all()
  end

  def create_or_update_yard(%Yard{} = yard, attrs \\ %{}) do
    cond do
      Ecto.get_meta(yard, :state) == :built -> create_yard(yard, attrs)
      true -> update_yard(yard, attrs)
    end
  end

  def create_yard(%Yard{} = yard, attrs \\ %{}) do
    {result, new_yard} =
      yard
      |> Yard.changeset(attrs)
      |> Repo.insert()

    if result == :ok, do: set_default_roles(new_yard)

    notify_subscribers({result, new_yard}, [:yard, :created])
  end

  def update_yard(%Yard{} = yard, attrs \\ %{}) do
    yard
    |> Yard.changeset(attrs)
    |> Repo.update()
    |> notify_subscribers([:yard, :updated])
  end

  defp set_default_roles(yard) do
    roles =
      Role
      |> where([r], r.default and is_nil(r.yard_id))
      |> Repo.all()
      |> Repo.preload(:permissions)

    [%{name: "Admin", description: "Admin for #{yard.name} yard", permissions: []} | roles]
    |> Enum.each(fn r ->
      permissions = Enum.map(r.permissions, &(%{"permission_id" => &1.id}))
      params = %{
        "yard_id" => yard.id,
        "name" => "#{yard.name} #{r.name}",
        "description" => r.description,
        "default" => true,
        "default_role_id" => Map.get(r, :id),
        "role_permissions" => permissions,
        "yard_admin" => (r.name == "Admin")
      }
      Roles.create_or_update_role(%Role{}, params)
    end)
  end

  def delete_yard(%Yard{} = yard) do
    Repo.delete(yard)
    |> notify_subscribers([:yard, :deleted])
  end

  def change_yard(%Yard{} = yard, attrs \\ %{}) do
    Yard.changeset(yard, attrs)
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(TentativeShip.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(TentativeShip.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
