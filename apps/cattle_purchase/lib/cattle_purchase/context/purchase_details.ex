defmodule CattlePurchase.PurchaseDetails do
  alias CattlePurchase.{
    PurchaseDetail,
    Repo
  }

  import Ecto.Query, only: [from: 2]

  @doc """
  Get purchase_detail from purchase
  """
  def get_purchase_detail_from_purchase(purchase_id) do
    from(purchase_detail in PurchaseDetail, where: purchase_detail.purchase_id == ^purchase_id)
    |> Repo.all()
  end

  @doc """
  Create a new purchase_detail
  """
  def new_purchase_detail() do
    PurchaseDetail.new_changeset(%PurchaseDetail{}, %{})
  end

  def change_purchase_detail(%PurchaseDetail{} = purchase_detail, attrs \\ %{}) do
    PurchaseDetail.changeset(purchase_detail, attrs)
  end

  def validate(%PurchaseDetail{} = purchase_detail, attrs \\ %{}) do
    purchase_detail
    |> change_purchase_detail(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a purchase_detail
  """
  def create_or_update_purchase_detail(%PurchaseDetail{} = purchase_detail, attrs \\ %{}) do
    purchase_detail
    |> PurchaseDetail.changeset(attrs)
    |> Repo.insert_or_update()
  end

  def update_validate(%PurchaseDetail{} = purchase_detail, attrs \\ %{}) do
    purchase_detail
    |> change_purchase_detail(attrs)
  end

  def create_or_update_multiple_purchase_details(cs_list, is_edit) do
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

  def delete_purchase_detail(%PurchaseDetail{} = purchase_detail) do
    Repo.delete(purchase_detail)
  end
end
