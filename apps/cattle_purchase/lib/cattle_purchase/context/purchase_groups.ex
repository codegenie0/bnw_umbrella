defmodule CattlePurchase.PurchaseGroups do
  alias CattlePurchase.{
    PurchaseGroup,
    Repo
  }

  @doc """
  List all purchase_groups
  """

  def list_purchase_groups() do
    Repo.all(PurchaseGroup)
  end

  @doc """
  Create a new purchase_group
  """
  def new_purchase_group() do
    PurchaseGroup.new_changeset(%PurchaseGroup{}, %{})
  end

  def change_purchase_group(%PurchaseGroup{} = purchase_group, attrs \\ %{}) do
    PurchaseGroup.changeset(purchase_group, attrs)
  end

  def validate(%PurchaseGroup{} = purchase_group, attrs \\ %{}) do
    purchase_group
    |> change_purchase_group(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a purchase_group
  """
  def create_or_update_purchase_group(%PurchaseGroup{} = purchase_group, attrs \\ %{}) do
    purchase_group
    |> PurchaseGroup.changeset(attrs)
    |> Repo.insert_or_update()
  end

  @doc """
  Delete a purchase type
  """
  def delete_purchase_group(%PurchaseGroup{} = purchase_group) do
    Repo.delete(purchase_group)
  end
end
