defmodule TentativeShip.Repo.Migrations.Schedules do
  use Ecto.Migration

  def change do
    create table(:schedules) do
      add :name, :string, null: false
      add :description, :text
      add :active, :boolean, default: true, null: false
      add :running_inventory, :boolean, default: false, null: false
      add :monitor, :boolean, default: false, null: false
      add :yard_id, references(:yards, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:schedules, [:name, :yard_id], name: :schedules_unique_index)
  end
end
