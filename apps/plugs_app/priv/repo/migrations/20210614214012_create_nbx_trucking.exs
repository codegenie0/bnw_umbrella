defmodule PlugsApp.Repo.Migrations.CreateNbxTrucking do
  use Ecto.Migration

  def change do
    create table(:nbx_trucking) do
      add :start_date, :date
      add :truck,      :integer
      add :dept,       :integer
      add :miles,      :integer
      add :tons,       :integer
    end
  end
end
