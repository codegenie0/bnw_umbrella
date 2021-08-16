defmodule PlugsApp.Repo.Migrations.CreateProfitCenterKeyCompanies do
  use Ecto.Migration

  def change do
    create table(:turnkey_profit_center_key_companies) do
      add :company, :string

      timestamps()
    end

    create unique_index(:turnkey_profit_center_key_companies, [:company], name: :tk_company_unique_key)
  end
end
