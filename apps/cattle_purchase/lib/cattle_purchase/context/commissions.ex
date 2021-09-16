defmodule CattlePurchase.Commissions do
  alias CattlePurchase.{
    Commission,
    Repo
  }

  import Ecto.Query, only: [from: 2]

  @doc """
  Get commission from purchase
  """
 def get_commission_from_purchase(purchase_id) do
  from(commission in Commission, where: commission.purchase_id == ^purchase_id) |> Repo.one()
 end
  @doc """
  Create a new commission
  """
  def new_commission() do
    Commission.new_changeset(%Commission{}, %{})
  end


  def change_commission(%Commission{} = commission, attrs \\ %{}) do
    Commission.changeset(commission, attrs)
  end

  def validate(%Commission{} = commission, attrs \\ %{}) do
    commission
    |> change_commission(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a commission
  """
  def create_or_update_commission(%Commission{} = commission, attrs \\ %{}) do
    commission
    |> Commission.changeset(attrs)
    |> Repo.insert_or_update()
  end

  @doc """
  Delete a purchase type
  """
  def delete_commission(%Commission{} = commission) do
    Repo.delete(commission)
  end
end
