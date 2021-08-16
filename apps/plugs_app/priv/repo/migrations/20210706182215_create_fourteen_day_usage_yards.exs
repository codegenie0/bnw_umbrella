defmodule PlugsApp.Repo.Migrations.CreateFourteenDayUsageYards do
  use Ecto.Migration

  def change do
    create table(:fourteen_day_usage_yard) do
      add :yard, :string

      timestamps()
    end
    create unique_index(:fourteen_day_usage_yard, :yard, name: :fourteen_day_usage_yard_unique_constraint)
  end
end
