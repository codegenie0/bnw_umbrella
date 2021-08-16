defmodule PlugsApp.Repo.Migrations.CreateProfitCenterKey do
  use Ecto.Migration

  def change do
    create table(:turnkey_profit_center_key) do
      add :company,            :integer, null: false
      add :profit_center,      :integer
      add :profit_center_desc, :string

      timestamps()
    end

    create unique_index(:turnkey_profit_center_key, [:company, :profit_center], name: :turnkey_unique_constraint)
  end
end
