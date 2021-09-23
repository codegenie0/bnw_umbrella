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
    from(down_payment in DownPayment, where: down_payment.purchase_id == ^purchase_id)
    |> Repo.all()
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

  def update_validate(%DownPayment{} = down_payment, attrs \\ %{}) do
    down_payment
    |> change_down_payment(attrs)
  end

  @doc """
  Create or update a down_payment
  """
  def create_or_update_down_payment(%DownPayment{} = down_payment, attrs \\ %{}) do
    down_payment
    |> DownPayment.changeset(attrs)
    |> Repo.insert_or_update()
  end


  def create_or_update_multiple_commissions(cs_list, is_edit) do
    if(is_edit) do
      Repo.transaction(fn ->
        Enum.each(cs_list, &Repo.update!(&1, []))
      end)
    else
      Repo.transaction(fn ->
        Enum.each(cs_list, &Repo.insert!(&1, []))
      end)
    end
  end


  def create_multiple_down_payment(dp_list) do
    Repo.transaction(fn ->
      Enum.each(dp_list, &Repo.insert!(&1, []))
    end)
  end

  @doc """
  Delete a purchase type
  """
  def delete_down_payment(%DownPayment{} = down_payment) do
    Repo.delete(down_payment)
  end
end
