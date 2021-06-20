defmodule PlugsApp.Repo.Migrations.CreateProfitCenterKeyCompanies do
  use Ecto.Migration

  def change do
    create table(:turnkey_profit_center_key_companies) do
      add :company, :string
    end
  end
end
