defmodule CattlePurchase.AnimalSexOrders do
  alias CattlePurchase.{
    AnimalSexOrder,
    Sex,
    Repo
  }
  import Ecto.Query

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
  end

  @doc """
  Delete a purchase type
  """
  def delete_animal_sex_order(%AnimalSexOrder{} = animal_sex_order) do
    Repo.delete(animal_sex_order)
  end
end
