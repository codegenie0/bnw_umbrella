defmodule CattlePurchase.Repo.Migrations.CreateAnimalSexOrders do
  use Ecto.Migration

  def change do
    create table(:animal_sex_orders) do
      add :order, :integer, null: false, default: 0
      add :sex_id, references(:sexes, null: false, on_delete: :delete_all)

      timestamps()
    end
  end
end
