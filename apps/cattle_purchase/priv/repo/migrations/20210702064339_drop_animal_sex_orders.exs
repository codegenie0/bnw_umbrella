defmodule CattlePurchase.Repo.Migrations.DropAnimalSexOrders do
  use Ecto.Migration

  def change do
    drop table("animal_sex_orders")
  end
end
