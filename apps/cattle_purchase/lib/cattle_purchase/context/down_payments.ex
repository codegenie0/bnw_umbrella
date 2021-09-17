defmodule CattlePurchase.DownPayments do
  alias CattlePurchase.{
    DownPayment,
    Repo
  }

  import Ecto.Query, only: [from: 2]

  @doc """
  Get down_payment from purchase
  """
  def get_down_payment_from_purchase(purchase_id) do
    from(down_payment in DownPayment, where: down_payment.purchase_id == ^purchase_id) |> Repo.one()
  end

  @doc """
  Create a new down_payment
  """
  def new_down_payment() do
    DownPayment.new_changeset(%DownPayment{}, %{})
  end

  def change_down_payment(%DownPayment{} = down_payment, attrs \\ %{}) do
    DownPayment.changeset(down_payment, attrs)
  end

  def validate(%DownPayment{} = down_payment, attrs \\ %{}) do
    down_payment
    |> change_down_payment(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a down_payment
  """
  def create_or_update_down_payment(%DownPayment{} = down_payment, attrs \\ %{}) do
    down_payment
    |> DownPayment.changeset(attrs)
    |> Repo.insert_or_update()
  end

  @doc """
  Delete a purchase type
  """
  def delete_down_payment(%DownPayment{} = down_payment) do
    Repo.delete(down_payment)
  end
end
