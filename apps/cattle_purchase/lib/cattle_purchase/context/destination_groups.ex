defmodule CattlePurchase.DestinationGroups do
  alias CattlePurchase.{
    DestinationGroup,
    Repo
  }

  @doc """
  List all destination_groups
  """
  @topic "cattle_purchase:destination_groups"
  def subscribe(), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, @topic)
  def subscribe(id), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")
  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, @topic)
  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")

  def list_destination_groups() do
    Repo.all(DestinationGroup)
  end

  @doc """
  Create a new destination_group
  """
  def new_destination_group() do
    DestinationGroup.new_changeset(%DestinationGroup{}, %{})
  end

  def change_destination_group(%DestinationGroup{} = destination_group, attrs \\ %{}) do
    DestinationGroup.changeset(destination_group, attrs)
  end

  def validate(%DestinationGroup{} = destination_group, attrs \\ %{}) do
    destination_group
    |> change_destination_group(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a destination_group
  """
  def create_or_update_destination_group(%DestinationGroup{} = destination_group, attrs \\ %{}) do
    destination_group
    |> DestinationGroup.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:destination_groups, :created_or_updated])

  end

  @doc """
  Delete a destination group
  """
  def delete_destination_group(%DestinationGroup{} = destination_group) do
    Repo.delete(destination_group)
    |> notify_subscribers([:destination_groups, :deleted])

  end

  def notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end

  def notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
