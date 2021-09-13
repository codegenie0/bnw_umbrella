defmodule CattlePurchase.Backgrounds do
  alias CattlePurchase.{
    Background,
    Repo
  }

  import Ecto.Query, only: [from: 2]
  @topic "cattle_purchase:backgrounds"

  def subscribe(), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, @topic)
  def subscribe(id), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")
  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, @topic)
  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")

  @doc """
  List all backgrounds
  """

  def list_backgrounds() do
    Repo.all(Background)
  end

  def get_inactive_backgrounds() do
    from(p in Background,
      where: p.active != true
    )
    |> Repo.all()
  end

  def get_active_backgrounds() do
    from(p in Background,
      where: p.active == true
    )
    |> Repo.all()
  end

  @doc """
  Create a new background
  """
  def new_background() do
    Background.new_changeset(%Background{}, %{})
  end

  def change_background(%Background{} = background, attrs \\ %{}) do
    Background.changeset(background, attrs)
  end

  def validate(%Background{} = background, attrs \\ %{}) do
    background
    |> change_background(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a background
  """
  def create_or_update_background(%Background{} = background, attrs \\ %{}) do
    background
    |> Background.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:backgrounds, :created_or_updated])
  end

  @doc """
  Delete a purchase type
  """
  def delete_background(%Background{} = background) do
    Repo.delete(background)
    |> notify_subscribers([:backgrounds, :deleted])
  end

  def notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, "#{@topic}:#{result.id}", {event, result})

    {:ok, result}
  end

  def notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
