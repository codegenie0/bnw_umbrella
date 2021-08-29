defmodule CattlePurchase.Purchases do
  alias CattlePurchase.{
    Purchase,
    PurchaseType,
    PurchaseTypeFilter,
    PurchaseTypePurchaseTypeFilter,
    PurchaseBuyer,
    PurchaseGroup,
    Destination,
    DestinationGroup,
    CattleReceiving,
    Shipment,
    Sex,
    Repo
  }

  import Ecto.Query

  @topic "cattle_purchase:purchases"
  def subscribe(), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, @topic)
  def subscribe(id), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")
  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, @topic)
  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")

  @doc """
  List all purchases
  """

  def list_purchases() do
    Repo.all(Purchase)
    |> Repo.preload([:sex, :purchase_buyer, :destination_group])
  end

  @doc """
  Create a new purchase
  """
  def new_purchase() do
    Purchase.new_changeset(%Purchase{}, %{})
  end

  def change_purchase(%Purchase{} = purchase, attrs \\ %{}) do
    Purchase.changeset(purchase, attrs)
  end

  def validate(%Purchase{} = purchase, attrs \\ %{}) do
    purchase
    |> change_purchase(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a purchase
  """
  def create_or_update_purchase(%Purchase{} = purchase, attrs \\ %{}) do
    purchase
    |> Purchase.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:purchases, :created_or_updated])
  end

  @doc """
  Delete a purchase type
  """
  def delete_purchase(%Purchase{} = purchase) do
    Repo.delete(purchase)
    |> notify_subscribers([:purchases, :deleted])
  end

  def filter_by_purhcase_types(query, []), do: query

  def filter_by_purhcase_types(query, purchase_type_ids) do
    query =
      from(p in query,
        join: pt in PurchaseType,
        on: p.purchase_type_id == pt.id
      )

    Enum.reduce(purchase_type_ids, query, fn purchase_type_id, query ->
      from([p, ..., q] in query,
        or_where: q.id == ^purchase_type_id
      )
    end)
  end

  def filter_by_purchase_type_filter(query, []), do: query

  def filter_by_purchase_type_filter(query, purchase_type_filter_ids) do
    purchase_type_ids =
      from(ptf in PurchaseTypeFilter,
        join: ptptf in PurchaseTypePurchaseTypeFilter,
        on: ptptf.purchase_type_filter_id == ptf.id,
        join: pt in PurchaseType,
        on: ptptf.purchase_type_id == pt.id,
        where: ptf.id in ^purchase_type_filter_ids,
        select: pt.id
      )
      |> Repo.all()

    filter_by_purhcase_types(query, purchase_type_ids)
  end

  def ship_date_range(query, nil, _end_date), do: query

  def ship_date_range(query, start_date, nil) do
    from(p in query,
      where: p.estimated_ship_date >= ^start_date
    )
  end

  def ship_date_range(query, start_date, end_date) do
    from(p in query,
      where:
        p.estimated_ship_date >= ^start_date and
          p.estimated_ship_date <= ^end_date
    )
  end

  def get_complete_purchases(query, false), do: query

  def get_complete_purchases(query, true) do
    from(p in query,
      where: p.complete == true
    )
  end

  def search(query, nil, _value), do: query

  def search(query, column, text)
      when column not in [
             "head_count",
             "weight",
             "price",
             "ship_date",
             "purchase_date",
             "sex",
             "buyer"
           ] do
    column = String.to_atom(column)

    from(p in query,
      where: like(field(p, ^column), ^"%#{text}%")
    )
  end

  def search(query, column, numerical_value)
      when column in ["head_count", "weight", "price", "ship_date", "purchase_date"] do
    column = String.to_atom(column)

    from(p in query,
      where: field(p, ^column) == ^numerical_value
    )
  end

  def search(query, column, text) when column in ["sex", "buyer"] do
    case column do
      "sex" ->
        from(p in query,
          join: sex in Sex,
          on: p.sex_id == sex.id,
          where: like(sex.name, ^"%#{text}%")
        )

      "buyer" ->
        from(p in query,
          join: pb in PurchaseBuyer,
          on: p.buyer_id == pb.id,
          where: like(pb.name, ^"%#{text}%")
        )

      _ ->
        query
    end
  end

  def sort_by(query, nil, _field), do: query

  def sort_by(query, sort_order, field) do
    sort_order = String.to_atom(sort_order)
    field = String.to_atom(field)

    from(p in query,
      order_by: [{^sort_order, ^field}]
    )
  end

  def get_purchase_type_filters() do
    PurchaseTypeFilter
    |> Repo.all()
  end

  def get_buyers(query) do
    from(pb in PurchaseBuyer,
      where: like(pb.name, ^"%#{query}%"),
      select: %{name: pb.name, id: pb.id}
    )
    |> Repo.all()
    |> Enum.map(fn record -> %{id: record.id, name: "#{record.name}-#{record.id}"} end)
  end

  def get_destination(query) do
    destination_query = from(des in Destination, where: des.active == true, order_by: des.name)

    from(dg in DestinationGroup,
      left_join: d in Destination,
      on: dg.id == d.destination_group_id,
      group_by: dg.id,
      order_by: dg.name,
      where: like(dg.name, ^"%#{query}%") or (d.active == true and like(d.name, ^"%#{query}%")),
      preload: [destinations: ^destination_query]
    )
    |> Repo.all()
  end

  def get_sex(query) do
    from(sex in Sex,
      where: like(sex.name, ^"%#{query}%")
    )
    |> Repo.all()
  end

  def get_purchase_group(query) do
    from(pg in PurchaseGroup,
      where: like(pg.name, ^"%#{query}%")
    )
    |> Repo.all()
  end

  def get_purchase_type(query) do
    from(pt in PurchaseType,
      where: like(pt.name, ^"%#{query}%") and pt.active == true
    )
    |> Repo.all()
  end

  def price_and_delivery(purchase) do
    if purchase.freight do
      Decimal.add(purchase.price, purchase.freight)
    else
      purchase.price
    end
  end

  def pcc_sort_category do
    for n <- ?A..?Z, do: <<n::utf8>>
  end

  def parse_date(date) do
    Timex.format!(date, "{0M}-{0D}-{YYYY}")
  end

  def check_days_diff_gt(purchase_id) do
    purchase =
      Repo.get(Purchase, purchase_id)
      |> Repo.preload([:shipments])

    if purchase.shipments == [] do
      false
    else
      shipments_gt_purchase =
        Enum.reduce(purchase.shipments, [], fn shipment, acc ->
          days = Date.diff(shipment.projected_out_date, purchase.projected_out_date)

          if days >= 30 do
            acc ++ [true]
          else
            acc ++ [false]
          end
        end)

      if true in shipments_gt_purchase, do: true, else: false
    end
  end

  def check_cattle_received_count(purchase_id) do
    from(cattle_receiving in CattleReceiving,
      join: shipment in Shipment,
      on: cattle_receiving.shipment_id == shipment.id,
      where: shipment.purchase_id == ^purchase_id,
      select: sum(cattle_receiving.number_received)
    )
    |> Repo.one()
  end

  def get_cattle_receiving_count(shipment_id) do
    from(cattle_receiving in CattleReceiving,
      where: cattle_receiving.shipment_id == ^shipment_id,
      select: cattle_receiving.number_received
    )
    |> Repo.one()
  end

  def list_purchases_by_page(current_page \\ 1, per_page \\ 10) do
    offset = per_page * (current_page - 1)

    Purchase
    |> offset(^offset)
    |> limit(^per_page)
    |> Repo.all()
    |> Repo.preload([:sex, :purchase_buyer, :destination_group, :shipments])
  end

  def total_pages(per_page \\ 10) do
    purchase_count =
      Purchase
      |> Repo.aggregate(:count, :id)

    (purchase_count / per_page)
    |> Decimal.from_float()
    |> Decimal.round(0, :up)
    |> Decimal.to_integer()
  end

  def get_purchases_data_total_pages(per_page \\ 10, search \\ "") do
    purchase_count =
      Purchase
      |> Repo.all()
      |> Enum.count()

    (purchase_count / per_page)
    |> Decimal.from_float()
    |> Decimal.round(0, :up)
    |> Decimal.to_integer()
  end

  def notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end

  def notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
