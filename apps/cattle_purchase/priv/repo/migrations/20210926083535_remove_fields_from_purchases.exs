defmodule CattlePurchase.Repo.Migrations.RemoveFieldsFromPurchases do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE purchases DROP FOREIGN KEY purchases_sex_id_fkey;"
    alter table(:purchases) do
      remove :sex_id
      remove :weight
      remove :price
      remove :projected_break_even
      remove :projected_out_date
      remove :head_count
      remove :seller
      remove :origin
      remove :purchase_basis
    end
  end
end
