defmodule CattlePurchase.Repo.Migrations.CreateBackgrounds do
  use Ecto.Migration

  def change do
    create table(:backgrounds) do
      add :name, :string, null: false
      add :description, :string
      add :active, :boolean, default: false, null: false

      timestamps()
    end
  end
end
