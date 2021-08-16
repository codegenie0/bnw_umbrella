defmodule PlugsApp.Repo.Migrations.CreateOutsideBillingCustomer do
  use Ecto.Migration

  def change do
    create table(:outside_billing_customer) do
      add :customer, :string, null: false

      timestamps()
    end

    create unique_index(:outside_billing_customer, :customer, name: :ob_customer_unique_key)
  end
end
