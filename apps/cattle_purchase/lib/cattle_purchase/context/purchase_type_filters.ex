defmodule CattlePurchase.PurchaseTypeFilters do
  alias CattlePurchase.{
    PurchaseTypeFilter,
    Repo,
    PurchaseTypePurchaseTypeFilter,
    PurchaseType
  }

  import Ecto.Query, only: [from: 2]
  @topic "cattle_purchase:purchase_type_filters"

  def subscribe(), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, @topic)
  def subscribe(id), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")
  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, @topic)
  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")

  @doc """
  List all purchase_type_filters
  """

  def list_purchase_type_filters() do
    from( ptf in PurchaseTypeFilter,
          join: ptfpt in PurchaseTypePurchaseTypeFilter,
          on: ptf.id == ptfpt.purchase_type_filter_id,
          join: pt in PurchaseType,
          on: pt.id == ptfpt.purchase_type_id,
          preload: [:purchase_types],
          distinct: true
        )
        |>Repo.all()
  end


  @doc """
  Create a new purchase_type_filter
  """
  def new_purchase_type_filter() do
    PurchaseTypeFilter.new_changeset(%PurchaseTypeFilter{}, %{})
  end

  def change_purchase_type_filter(%PurchaseTypeFilter{} = purchase_type_filter, attrs \\ %{}) do
    PurchaseTypeFilter.changeset(purchase_type_filter, attrs)
  end

  def validate(%PurchaseTypeFilter{} = purchase_type_filter, attrs \\ %{}) do
    purchase_type_filter
    |> change_purchase_type_filter(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a purchase_type_filter
  """
  def create_or_update_purchase_type_filter(%PurchaseTypeFilter{} = purchase_type_filter, attrs \\ %{}) do
    purchase_type_filter
    |> PurchaseTypeFilter.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:purchase_type_filters, :created_or_updated])
  end

  @doc """
  Delete a purchase type filter
  """
  def delete_purchase_type_filter(%PurchaseTypeFilter{} = purchase_type_filter) do
    Repo.delete(purchase_type_filter)
    |> notify_subscribers([:purchase_type_filters, :deleted])
  end

  @doc """
  Check if any acitve purchase type exist
  """
  def check_active_purchase_types_exist?() do
    result = from( p in CattlePurchase.PurchaseType,
                    where: p.active == true
                  )
                  |> Repo.all()

    if result == [], do: false, else: true
  end

  @doc """
    set previous purchase type filter default groups to false
  """
  def set_default_group_to_false() do
    from( ptf in PurchaseTypeFilter,
          where: ptf.default_group == true,
          update: [set: [default_group: false]]
        )
        |> Repo.update_all([])
  end

  def notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, "#{@topic}:#{result.id}", {event, result})

    {:ok, result}
  end

  def notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
