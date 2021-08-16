defmodule TentativeShip.Repo.Migrations.CreateLotStatusCodes do
  use Ecto.Migration

  def change do
    create table(:lot_status_codes) do
      add :name, :string, null: false
      add :description, :text
      add :yard_id, references(:yards, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:lot_status_codes, [:name, :yard_id], name: :lot_status_codes_unique_index)
  end
end
