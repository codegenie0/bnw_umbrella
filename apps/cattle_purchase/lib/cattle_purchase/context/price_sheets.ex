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
    sex_query = from(sex in CattlePurchase.Sex, order_by: sex.order)

    result =
      from(price_sheet in CattlePurchase.PriceSheet,
        join: price_sheet_details in CattlePurchase.PriceSheetDetail,
        on: price_sheet.id == price_sheet_details.price_sheet_id,
        join: w_c in CattlePurchase.WeightCategory,
        on: w_c.id == price_sheet_details.weight_category_id,
        group_by: price_sheet.id,
        order_by: [desc: price_sheet.price_date],
        preload: [price_sheet_details: [:weight_category, sex: ^sex_query]]
      )
      |> Repo.all()

    Enum.reduce(result, [], fn res, acc ->
      result =
        Enum.group_by(res.price_sheet_details, fn resp -> resp.weight_category.start_weight end)

      map = Map.put(res, :price_sheet_details, result)
      acc ++ [map]
    end)
  end

  def get_weight_categories() do
    from(wc in CattlePurchase.WeightCategory,
      select: wc.start_weight
    )
    |> CattlePurchase.Repo.all()
  end

  def get_active_sex_with_order() do
    from(sex in CattlePurchase.Sex,
      where: sex.active == true,
      order_by: sex.order,
      select: sex.name
    )
    |> CattlePurchase.Repo.all()
  end

  def price_date_range(_query, nil, _end_date), do: list_price_sheets()

  def price_date_range(query, start_date, nil) do
    sex_query = from(sex in CattlePurchase.Sex, order_by: sex.order)

    result =
      from(price_sheet in query,
        join: price_sheet_details in CattlePurchase.PriceSheetDetail,
        on: price_sheet.id == price_sheet_details.price_sheet_id,
        join: w_c in CattlePurchase.WeightCategory,
        on: w_c.id == price_sheet_details.weight_category_id,
        where: price_sheet.price_date >= ^start_date,
        group_by: price_sheet.id,
        order_by: [desc: price_sheet.price_date],
        preload: [price_sheet_details: [:weight_category, sex: ^sex_query]]
      )
      |> Repo.all()

    Enum.reduce(result, [], fn res, acc ->
      result =
        Enum.group_by(res.price_sheet_details, fn resp -> resp.weight_category.start_weight end)

      map = Map.put(res, :price_sheet_details, result)
      acc ++ [map]
    end)
  end

  def price_date_range(query, start_date, end_date) do
    sex_query = from(sex in CattlePurchase.Sex, order_by: sex.order)

    result =
      from(price_sheet in query,
        join: price_sheet_details in CattlePurchase.PriceSheetDetail,
        on: price_sheet.id == price_sheet_details.price_sheet_id,
        join: w_c in CattlePurchase.WeightCategory,
        on: w_c.id == price_sheet_details.weight_category_id,
        where: price_sheet.price_date >= ^start_date and price_sheet.price_date <= ^end_date,
        group_by: price_sheet.id,
        order_by: [desc: price_sheet.price_date],
        preload: [price_sheet_details: [:weight_category, sex: ^sex_query]]
      )
      |> Repo.all()

    Enum.reduce(result, [], fn res, acc ->
      result =
        Enum.group_by(res.price_sheet_details, fn resp -> resp.weight_category.start_weight end)

      map = Map.put(res, :price_sheet_details, result)
      acc ++ [map]
    end)
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
