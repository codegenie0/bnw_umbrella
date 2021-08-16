defmodule PlugsApp.Repo.Migrations.CreateOutsideBilling do
  use Ecto.Migration

  def change do
    create table(:outside_billing) do
      add :service_date, :date
      add :location,     :integer, null: false
      add :quantity,     :decimal, precision: 12, scale: 1, default: 0.0
      add :price,        :decimal, precision: 12, scale: 2, default: 0.00
      add :no_charge,    :boolean, default: false
      add :pass_thru,    :boolean, default: false
      add :comments,     :string
      add :service_type, :integer, null: false

      timestamps()
    end

    create unique_index(:outside_billing, [
          :service_date,
          :location,
          :service_type,
          :comments
        ],
        name: :outside_billing_unique_key)
  end
end
