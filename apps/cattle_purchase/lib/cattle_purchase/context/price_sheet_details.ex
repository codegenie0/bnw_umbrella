defmodule CattlePurchase.PurchaseSheetDetails do
  alias CattlePurchase.{
    PriceSheetDetail,
    PriceSheet,
    Repo
  }
  import Ecto.Query, only: [from: 2]

  @topic "cattle_purchase:price_sheet_details"
  def subscribe(), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, @topic)
  def subscribe(id), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")
  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, @topic)
  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")

  @doc """
  List all price_sheet_details
  """

  def list_price_sheet_details(price_sheet_id) do
    from(psd in PriceSheetDetail,
          where: psd.price_sheet_id == ^price_sheet_id
    )
    |> Repo.all()
  end

  @doc """
  Create a new price_sheet_detail
  """
  def new_price_sheet_detail() do
    PriceSheetDetail.new_changeset(%PriceSheetDetail{}, %{})
  end

  def change_price_sheet_detail(%PriceSheetDetail{} = price_sheet_detail, attrs \\ %{}) do
    PriceSheetDetail.changeset(price_sheet_detail, attrs)
  end

  def validate(%PriceSheetDetail{} = price_sheet_detail, attrs \\ %{}) do
    price_sheet_detail
    |> change_price_sheet_detail(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a price_sheet_detail
  """
  def create_or_update_price_sheet_detail(%PriceSheetDetail{} = price_sheet_detail, attrs \\ %{}) do
    price_sheet_detail
    |> PriceSheetDetail.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:price_sheet_details, :created_or_updated])
  end

  @doc """
  Delete a price_sheet_detail
  """
  def delete_price_sheet_detail(%PriceSheetDetail{} = price_sheet_detail) do
    Repo.delete(price_sheet_detail)
    |> notify_subscribers([:price_sheet_details, :deleted])

  end

  def notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end
  def notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
