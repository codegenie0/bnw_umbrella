defmodule CattlePurchase.PurchasePayees do
  alias CattlePurchase.{
    PurchasePayee,
    Repo
  }

  import Ecto.Query, only: [from: 2]

  @doc """
  Get purchase_payee from purchase
  """
  def get_payee_from_purchase_id(purchase_id) do
    from(purchase_payee in PurchasePayee, where: purchase_payee.purchase_id == ^purchase_id)
    |> Repo.one()
  end

  @doc """
  Create a new purchase_payee
  """
  def new_purchase_payee() do
    PurchasePayee.new_changeset(%PurchasePayee{}, %{})
  end

  def change_purchase_payee(%PurchasePayee{} = purchase_payee, attrs \\ %{}) do
    PurchasePayee.changeset(purchase_payee, attrs)
  end

  def validate(%PurchasePayee{} = purchase_payee, attrs \\ %{}) do
    purchase_payee
    |> change_purchase_payee(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a purchase_payee
  """
  def create_or_update_purchase_payee(%PurchasePayee{} = purchase_payee, attrs \\ %{}) do
    purchase_payee
    |> PurchasePayee.changeset(attrs)
    |> Repo.insert_or_update()
  end

  def delete_purchase_payee(%PurchasePayee{} = purchase_payee) do
    Repo.delete(purchase_payee)
  end
end
