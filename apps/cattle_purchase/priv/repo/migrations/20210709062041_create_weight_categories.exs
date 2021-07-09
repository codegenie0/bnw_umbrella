defmodule CattlePurchase.Repo.Migrations.CreateWeightCategories do
  use Ecto.Migration

  def change do
    create table(:weight_categories) do
      add :start_weight, :integer, null: false
      add :end_weight, :integer, null: false

      timestamps()
    end
  end
end
