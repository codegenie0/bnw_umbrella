defmodule CattlePurchase.States do
  alias CattlePurchase.{
    State,
    Repo
  }

  import Ecto.Query, only: [from: 2]
  @topic "cattle_purchase:states"

  def subscribe(), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, @topic)
  def subscribe(id), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")
  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, @topic)
  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")

  @doc """
  List all states
  """

  def list_states() do
    Repo.all(State)
  end

  def get_inactive_states() do
    from(p in State,
      where: p.active != true
    )
    |> Repo.all()
  end

  def get_active_states() do
    from(p in State,
      where: p.active == true
    )
    |> Repo.all()
  end

  @doc """
  Create a new state
  """
  def new_state() do
    State.new_changeset(%State{}, %{})
  end

  def change_state(%State{} = state, attrs \\ %{}) do
    State.changeset(state, attrs)
  end

  def validate(%State{} = state, attrs \\ %{}) do
    state
    |> change_state(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a state
  """
  def create_or_update_state(%State{} = state, attrs \\ %{}) do
    state
    |> State.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:states, :created_or_updated])
  end

  @doc """
  Delete a purchase type
  """
  def delete_state(%State{} = state) do
    Repo.delete(state)
    |> notify_subscribers([:states, :deleted])
  end

  def notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, "#{@topic}:#{result.id}", {event, result})

    {:ok, result}
  end

  def notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
