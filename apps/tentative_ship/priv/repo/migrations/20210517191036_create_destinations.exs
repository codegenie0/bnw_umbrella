defmodule TentativeShip.Repo.Migrations.CreateDestinations do
  use Ecto.Migration

  def change do
    create table(:destinations) do
      add :name, :string, null: false
      add :description, :text
      add :terminal, :boolean, default: true, null: false
      add :yard_id, references(:yards, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:destinations, [:name, :yard_id], name: :destinations_unique_index)
  end
end
