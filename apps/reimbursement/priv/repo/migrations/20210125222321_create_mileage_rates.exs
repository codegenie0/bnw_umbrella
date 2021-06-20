defmodule Reimbursement.Repo.Migrations.CreateMileageRates do
  use Ecto.Migration

  def change do
    create table(:mileage_rates) do
      add :year, :integer, null: false
      add :value, :decimal, precision: 12, scale: 3, default: 0.000, null: false
    end

    create unique_index(:mileage_rates, [:year], name: :year_unique_index)
  end
end
