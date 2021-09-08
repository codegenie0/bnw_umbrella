defmodule CattlePurchase.Repo.Migrations.CreatePrograms do
  use Ecto.Migration

  def change do
    create table(:programs) do
      add :name, :string, null: false
      add :description, :string
      add :active, :boolean, default: false, null: false

      timestamps()
    end
  end
end
