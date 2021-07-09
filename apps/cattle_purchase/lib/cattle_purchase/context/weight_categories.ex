defmodule CattlePurchase.WeightCategories do
  alias CattlePurchase.{
    WeightCategory,
    Repo
  }

  import Ecto.Query, only: [from: 2]
  @topic "cattle_purchase:weight_categories"
  def subscribe(), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, @topic)
  def subscribe(id), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")
  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, @topic)
  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")

  @doc """
  List all weight_categories
  """

  def list_weight_categories() do
    Repo.all(WeightCategory)
  end

  @doc """
  Create a new weight_category
  """
  def new_weight_category() do
    WeightCategory.new_changeset(%WeightCategory{}, %{})
  end

  def change_weight_category(%WeightCategory{} = weight_category, attrs \\ %{}) do
    WeightCategory.changeset(weight_category, attrs)
  end

  def validate(%WeightCategory{} = weight_category, attrs \\ %{}) do
    weight_category
    |> change_weight_category(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a weight_category
  """
  def create_or_update_weight_category(%WeightCategory{} = weight_category, attrs \\ %{}) do
    weight_category
    |> WeightCategory.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:weight_categories, :created_or_updated])

  end

  @doc """
  Delete a weight category
  """
  def delete_weight_category(%WeightCategory{} = weight_category) do
    Repo.delete(weight_category)
    |> notify_subscribers([:weight_categories, :deleted])
  end

  def check_weight_categories_overlapping(start_weight, end_weight) do
    from(wc in WeightCategory,
            where: wc.start_weight <= ^start_weight
              or wc.end_weight <= ^end_weight,
              select: %{id: wc.id}
        )
        |> Repo.all()

  end

  def notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end

  def notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
