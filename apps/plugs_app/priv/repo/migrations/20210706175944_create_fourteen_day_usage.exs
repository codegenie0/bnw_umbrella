defmodule PlugsApp.Repo.Migrations.CreateFourteenDayUsage do
  use Ecto.Migration

  def change do
    create table(:fourteen_day_usage) do
      add :yard,             :integer, null: false
      add :commodity,        :integer, null: false
      add :inventory_amount, :integer, default: 0
      add :usage_pounds,     :integer, default: 0
      add :receiving_pounds, :integer, default: 0

      timestamps()
    end

    create unique_index(:fourteen_day_usage, [
          :yard,
          :commodity,
          :inventory_amount,
          :usage_pounds,
          :receiving_pounds,
        ],
        name: :fourteen_day_usage_unique_key)
  end
end
