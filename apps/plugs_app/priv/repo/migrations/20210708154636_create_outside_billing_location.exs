defmodule PlugsApp.Repo.Migrations.CreateOutsideBillingLocation do
  use Ecto.Migration

  def change do
    create table(:outside_billing_location) do
      add :customer, :integer, null: false
      add :location, :string, null: false

      timestamps()
    end

    create unique_index(:outside_billing_location, [:customer, :location], name: :ob_location_unique_key)
  end
end
