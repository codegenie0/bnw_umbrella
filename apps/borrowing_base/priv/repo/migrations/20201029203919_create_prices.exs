defmodule BorrowingBase.Repo.Migrations.CreatePrices do
  use Ecto.Migration

  def change do
    create table(:prices) do
      add :gender, :string, null: false
      add :amount, :decimal, precision: 12, scale: 2, default: 0, null: false
      add :weight_group_id, references(:weight_groups, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:prices, [:gender, :weight_group_id], name: :prices_unique_index)
  end
end
