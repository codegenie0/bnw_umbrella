defmodule CattlePurchase.PurchaseTypes do
  alias CattlePurchase.{
    PurchaseType,
    Repo
  }

  @doc """
  List all purchase_types
  """

  def list_purchase_types() do
    Repo.all(PurchaseType)
  end

  @doc """
  Create a new purchase_type
  """
  def new_purchase_type() do
    PurchaseType.new_changeset(%PurchaseType{}, %{})
  end

  def change_purchase_type(%PurchaseType{} = purchase_type, attrs \\ %{}) do
    PurchaseType.changeset(purchase_type, attrs)
  end

  def validate(%PurchaseType{} = purchase_type, attrs \\ %{}) do
    purchase_type
    |> change_purchase_type(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a purchase_type
  """
  def create_or_update_purchase_type(%PurchaseType{} = purchase_type, attrs \\ %{}) do
    purchase_type
    |> PurchaseType.changeset(attrs)
    |> Repo.insert_or_update()
  end

  @doc """
  Delete a purchase type
  """
  def delete_purchase_type(%PurchaseType{} = purchase_type) do
    Repo.delete(purchase_type)
  end
end
