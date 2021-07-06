defmodule CattlePurchase.Destinations do
  alias CattlePurchase.{
    Destination,
    Repo
  }

  import Ecto.Query, only: [from: 2]

  @doc """
  List all active destinations
  """

  def list_active_destinations(parent_id) do
    from(destination in Destination,
          where: destination.destination_group_id == ^parent_id
            and destination.active == true
        )
        |> Repo.all()
  end

  @doc """
  List all inactive destinations
  """

  def list_inactive_destinations(parent_id) do
    from(destination in Destination,
          where: destination.destination_group_id == ^parent_id
            and destination.active == false
        )
        |> Repo.all()
  end

  @doc """
  Create a new destination_group
  """
  def new_destination() do
    Destination.new_changeset(%Destination{}, %{})
  end

  def change_destination(%Destination{} = destination, attrs \\ %{}) do
    Destination.changeset(destination, attrs)
  end

  def validate(%Destination{} = destination, attrs \\ %{}) do
    destination
    |> change_destination(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a destination
  """
  def create_or_update_destination(%Destination{} = destination, attrs \\ %{}) do
    destination
    |> Destination.changeset(attrs)
    |> Repo.insert_or_update()
  end

  @doc """
  Delete a destination
  """
  def delete_destination(%Destination{} = destination) do
    Repo.delete(destination)
  end
end
