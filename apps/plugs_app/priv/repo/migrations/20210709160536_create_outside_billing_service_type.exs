defmodule PlugsApp.Repo.Migrations.CreateOutsideBillingServiceType do
  use Ecto.Migration

  def change do
    create table(:outside_billing_service_type) do
      add :service_type, :string

      timestamps()
    end

    create unique_index(:outside_billing_service_type, [:service_type], name: :ob_st_unique_constraint)
  end
end
