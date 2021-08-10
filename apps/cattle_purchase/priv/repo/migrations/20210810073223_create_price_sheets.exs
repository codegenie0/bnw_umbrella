defmodule CattlePurchase.Repo.Migrations.CreatePriceSheets do
  use Ecto.Migration

  def change do
    create table(:price_sheets) do
      add :price_date, :date, null: false
      add :comment, :text

      timestamps()
    end
  end
end
