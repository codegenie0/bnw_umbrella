defmodule CattlePurchase.PurchaseFlags do
  alias CattlePurchase.{
    PurchaseFlag,
    Repo
  }

  @doc """
  List all purchase_flags
  """

  def list_purchase_flags() do
    Repo.all(PurchaseFlag)
  end

  @doc """
  Create a new purchase_flag
  """
  def new_purchase_flag() do
    PurchaseFlag.new_changeset(%PurchaseFlag{}, %{})
  end

  def change_purchase_flag(%PurchaseFlag{} = purchase_flag, attrs \\ %{}) do
    PurchaseFlag.changeset(purchase_flag, attrs)
  end

  def validate(%PurchaseFlag{} = purchase_flag, attrs \\ %{}) do
    purchase_flag
    |> change_purchase_flag(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a purchase_flag
  """
  def create_or_update_purchase_flag(%PurchaseFlag{} = purchase_flag, attrs \\ %{}) do
    purchase_flag
    |> PurchaseFlag.changeset(attrs)
    |> Repo.insert_or_update()
  end

  @doc """
  Delete a purchase type
  """
  def delete_purchase_flag(%PurchaseFlag{} = purchase_flag) do
    Repo.delete(purchase_flag)
  end
end
