defmodule CattlePurchase.Repo.Migrations.AddUniqueIndexForPriceDateInPriceSheets do
  use Ecto.Migration

  def change do
    create unique_index(:price_sheets, [:price_date])

  end
end
