defmodule TentativeShip.Repo.Migrations.CreateSexCodes do
  use Ecto.Migration

  def change do
    create table(:sex_codes) do
      add :name, :string, null: false
      add :description, :text
      add :yard_id, references(:yards, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:sex_codes, [:name, :yard_id], name: :sex_codes_unique_index)
  end
end
