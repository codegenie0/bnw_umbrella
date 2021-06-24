defmodule CattlePurchase.Repo.Migrations.CreateSexes do
  use Ecto.Migration

  def change do
    create table(:sexes) do
      add :name, :string, null: false
      add :code, :string

      timestamps()
    end
  end
end
