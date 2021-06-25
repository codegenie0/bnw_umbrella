defmodule CattlePurchase.Repo.Migrations.CreateDestinationGroups do
  use Ecto.Migration

  def change do
    create table(:destination_groups) do
      add :name, :string, null: false
      add :lft, :integer
      add :rgt, :integer

      timestamps()
    end
  end
end
