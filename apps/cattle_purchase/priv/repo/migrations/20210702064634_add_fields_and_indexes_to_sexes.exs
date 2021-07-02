defmodule CattlePurchase.Repo.Migrations.AddFieldsAndIndexesToSexes do
  use Ecto.Migration

  def change do
    alter table("sexes") do
      add :description, :text
      add :order, :integer, null: false
      add :active, :boolean, default: false
      remove :code

    end
    create unique_index(:sexes, [:name])
    create unique_index(:sexes, [:order])
  end
end
