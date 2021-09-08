defmodule CattlePurchase.Programs do
  alias CattlePurchase.{
    Program,
    Repo
  }

  import Ecto.Query, only: [from: 2]
  @topic "cattle_purchase:programs"

  def subscribe(), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, @topic)
  def subscribe(id), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")
  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, @topic)
  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")

  @doc """
  List all programs
  """

  def list_programs() do
    Repo.all(Program)
  end

  def get_inactive_programs() do
    from(p in Program,
      where: p.active != true
    )
    |> Repo.all()
  end

  def get_active_programs() do
    from(p in Program,
      where: p.active == true
    )
    |> Repo.all()
  end

  @doc """
  Create a new program
  """
  def new_program() do
    Program.new_changeset(%Program{}, %{})
  end

  def change_program(%Program{} = program, attrs \\ %{}) do
    Program.changeset(program, attrs)
  end

  def validate(%Program{} = program, attrs \\ %{}) do
    program
    |> change_program(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a program
  """
  def create_or_update_program(%Program{} = program, attrs \\ %{}) do
    program
    |> Program.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:programs, :created_or_updated])
  end

  @doc """
  Delete a purchase type
  """
  def delete_program(%Program{} = program) do
    Repo.delete(program)
    |> notify_subscribers([:programs, :deleted])
  end

  def notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, "#{@topic}:#{result.id}", {event, result})

    {:ok, result}
  end

  def notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
