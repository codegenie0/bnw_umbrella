defmodule CattlePurchase.Repo.Migrations.ChangeNumericDatatypesInPurchases do
  use Ecto.Migration

  def change do
    alter table(:purchases) do
      modify :weight, :integer
      modify :price, :decimal, precision: 10, scale: 2
      modify :projected_break_even, :decimal,  precision: 10, scale: 2
      modify :freight, :decimal,  precision: 10, scale: 2
    end
  end
end
