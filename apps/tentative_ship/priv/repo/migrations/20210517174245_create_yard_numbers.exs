defmodule TentativeShip.Repo.Migrations.CreateYardNumbers do
  use Ecto.Migration

  def change do
    create table(:yard_numbers) do
      add :name, :string, null: false
      add :description, :text
      add :yard_id, references(:yards, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:yard_numbers, [:name, :yard_id], name: :yard_numbers_unique_index)
  end
end
