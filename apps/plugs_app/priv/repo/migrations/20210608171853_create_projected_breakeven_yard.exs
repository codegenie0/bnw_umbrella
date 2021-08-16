defmodule PlugsApp.Repo.Migrations.CreateProjectedBreakevenYard do
  use Ecto.Migration

  def change do
    create table(:projected_breakeven_yard) do
      add :yard, :string

      timestamps()
    end
    create unique_index(:projected_breakeven_yard, :yard, name: :projected_breakeven_yard_unique_constraint)
  end
end
