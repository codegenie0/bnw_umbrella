defmodule CattlePurchase.Repo.Migrations.AddPrecisionToValueInPriceSheetDetails do
  use Ecto.Migration

  def change do
    alter table("price_sheet_details") do
      modify :value, :decimal,  precision: 10, scale: 2, default: 00.00
    end
  end
end
