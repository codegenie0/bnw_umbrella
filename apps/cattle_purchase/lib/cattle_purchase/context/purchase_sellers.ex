defmodule CattlePurchase.PurchaseSellers do
  alias CattlePurchase.{
    PurchaseSeller,
    Repo
  }

  import Ecto.Query, only: [from: 2]

  @doc """
  Get purchase_seller from purchase
  """
  def get_seller_from_purchase_id(purchase_id) do
    from(purchase_seller in PurchaseSeller, where: purchase_seller.purchase_id == ^purchase_id)
    |> Repo.one()
  end

  @doc """
  Create a new purchase_seller
  """
  def new_purchase_seller() do
    PurchaseSeller.new_changeset(%PurchaseSeller{}, %{})
  end

  def change_purchase_seller(%PurchaseSeller{} = purchase_seller, attrs \\ %{}) do
    PurchaseSeller.changeset(purchase_seller, attrs)
  end

  def validate(%PurchaseSeller{} = purchase_seller, attrs \\ %{}) do
    purchase_seller
    |> change_purchase_seller(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a purchase_seller
  """
  def create_or_update_purchase_seller(%PurchaseSeller{} = purchase_seller, attrs \\ %{}) do
    purchase_seller
    |> PurchaseSeller.changeset(attrs)
    |> Repo.insert_or_update()
  end

  def delete_purchase_seller(%PurchaseSeller{} = purchase_seller) do
    Repo.delete(purchase_seller)
  end
end
