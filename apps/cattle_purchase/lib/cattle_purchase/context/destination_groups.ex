defmodule CattlePurchase.DestinationGroups do
  alias CattlePurchase.{
    DestinationGroup,
    Repo
  }

  @doc """
  List all destination_groups
  """

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
  end

  @doc """
  Delete a purchase type
  """
  def delete_destination_group(%DestinationGroup{} = destination_group) do
    Repo.delete(destination_group)
  end
end
