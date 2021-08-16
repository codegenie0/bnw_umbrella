defmodule PlugsApp.Repo.Migrations.CreateFourteenDayUsageCommodities do
  use Ecto.Migration

  def change do
    create table(:fourteen_day_usage_commodity) do
      add :yard,             :integer, null: false
      add :commodity_number, :integer, null: false
      add :commodity_name,   :string
      add :part_of_ration,   :boolean

      timestamps()
    end

    create unique_index(:fourteen_day_usage_commodity, [:commodity_number, :yard], name: :usage_commodity_number_unique_key)
    create unique_index(:fourteen_day_usage_commodity, [:commodity_name, :yard], name: :usage_commodity_name_unique_key)
  end
end
