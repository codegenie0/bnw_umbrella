defmodule CattlePurchase.Repo.Migrations.CreateDestinations do
  use Ecto.Migration

  def change do
    create table(:destinations) do
      add :name, :string, null: false
      add :destination_group_id, references(:destination_groups, null: false, on_delete: :delete_all)
      add :active, :boolean, default: false
      timestamps()
    end
  end
end
