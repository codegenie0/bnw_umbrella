defmodule CattlePurchase.Repo.Migrations.AddDefaultValueForPriceSheetDetails do
  use Ecto.Migration

  def change do
    alter table("price_sheet_details") do
      modify :value, :decimal, default: 00.00
    end
  end
end
