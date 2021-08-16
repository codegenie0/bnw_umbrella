defmodule PlugsApp.Repo.Migrations.CreateNbxTrucking do
  use Ecto.Migration

  def change do
    create table(:nbx_trucking) do
      add :start_date, :date
      add :truck,      :integer
      add :dept,       :integer, null: false
      add :miles,      :integer
      add :tons,       :integer

      timestamps()
    end

    create unique_index(:nbx_trucking, [:start_date, :truck, :dept], name: :nbx_trucking_unique_constraint)
  end
end
