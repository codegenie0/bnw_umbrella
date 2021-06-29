defmodule CattlePurchase.AnimalSexOrders do
  alias CattlePurchase.{
    AnimalSexOrder,
    Sex,
    Repo
  }
  import Ecto.Query

  @topic "cattle_purchase:animal_sex_orders"

  def subscribe(), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, @topic)
  def subscribe(id), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")
  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, @topic)
  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")

  @doc """
  List all animal_sex_orders
  """

  def list_animal_sex_orders() do
    animal_sex_order_query = from(aso in AnimalSexOrder, order_by: [desc: aso.id])
    from( s in Sex, join: aso in AnimalSexOrder,
            on: s.id == aso.sex_id,
            preload: [animal_sex_order: ^animal_sex_order_query],
            distinct: true
        )
        |> Repo.all()
  end

  @doc """
  Create a new animal_sex_order
  """
  def new_animal_sex_order() do
    AnimalSexOrder.new_changeset(%AnimalSexOrder{}, %{})
  end

  def get_all_sexes() do
    Repo.all(Sex)
  end

  def change_animal_sex_order(%AnimalSexOrder{} = animal_sex_order, attrs \\ %{}) do
    AnimalSexOrder.changeset(animal_sex_order, attrs)
  end

  def validate(%AnimalSexOrder{} = animal_sex_order, attrs \\ %{}) do
    animal_sex_order
    |> change_animal_sex_order(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a animal_sex_order
  """
  def create_or_update_animal_sex_order(%AnimalSexOrder{} = animal_sex_order, attrs \\ %{}) do
    animal_sex_order
    |> AnimalSexOrder.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:animal_sex_orders, :created_or_updated])
  end

  def notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, "#{@topic}:#{result.id}", {event, result})

    {:ok, result}
  end

  def notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
