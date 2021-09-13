defmodule CattlePurchase.Repo.Migrations.CreateStates do
  use Ecto.Migration

  def change do
    create table(:states) do
      add :name, :string, null: false
      add :description, :string
      add :active, :boolean, default: false, null: false

      timestamps()
    end
  end
end
