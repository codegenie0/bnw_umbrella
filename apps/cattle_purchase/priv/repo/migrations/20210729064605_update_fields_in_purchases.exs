defmodule CattlePurchase.Repo.Migrations.UpdateFieldsInPurchases do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE purchases DROP FOREIGN KEY purchases_sex_id_fkey;"
    execute "ALTER TABLE purchases DROP FOREIGN KEY purchases_future_destination_group_id_fkey;"
    execute "ALTER TABLE purchases DROP FOREIGN KEY purchases_buyer_id_fkey;"
    alter table(:purchases) do
      modify :sex_id, references(:sexes)
      modify :future_destination_group_id, references(:destination_groups)
      modify :buyer_id, references(:purchase_buyers)
      modify :destination_group_name, :string
    end
  end
end
