defmodule PlugsApp.Repo.Migrations.CreateProfitCenterKey do
  use Ecto.Migration

  def change do
    create table(:turnkey_profit_center_key) do
      add :company,            :integer
      add :profit_center,      :integer
      add :profit_center_desc, :string
    end
  end
end
