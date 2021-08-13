defmodule CattlePurchase.PurchaseSheets do
  alias CattlePurchase.{
    PriceSheet,
    Repo
  }

  import Ecto.Query, only: [from: 2]

  @topic "cattle_purchase:price_sheets"
  def subscribe(), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, @topic)
  def subscribe(id), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")
  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, @topic)
  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")

  @doc """
  List all price_sheets
  """

  def list_price_sheets() do
    PriceSheet
    |> Repo.all()
    |> Repo.preload(:price_sheet_details)
  end

  @doc """
  Create a new price_sheet
  """
  def new_price_sheet() do
    PriceSheet.new_changeset(%PriceSheet{}, %{})
  end

  def change_price_sheet(%PriceSheet{} = price_sheet, attrs \\ %{}) do
    PriceSheet.changeset(price_sheet, attrs)
  end

  def validate(%PriceSheet{} = price_sheet, attrs \\ %{}) do
    price_sheet
    |> change_price_sheet(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a price_sheet
  """
  def create_or_update_price_sheet(%PriceSheet{} = price_sheet, attrs \\ %{}) do
    price_sheet
    |> PriceSheet.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:price_sheets, :created_or_updated])
  end

  @doc """
  Delete a price_sheet
  """
  def delete_price_sheet(%PriceSheet{} = price_sheet) do
    Repo.delete(price_sheet)
    |> notify_subscribers([:price_sheets, :deleted])
  end

  def notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end

  def notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
