defmodule CattlePurchase.Repo.Migrations.CreatePriceSheetDetails do
  use Ecto.Migration

  def change do
    create table(:price_sheet_details) do
      add :sex_id, references(:sexes, null: false)
      add :weight_category_id, references(:weight_categories, null: false)
      add :price_sheet_id, references(:price_sheets, null: false)
      add :value, :decimal, precision: 10, scale: 2


      timestamps()
    end
  end
end
