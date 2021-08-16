defmodule TentativeShip.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :name, :string, null: false
      add :yard_admin, :boolean, default: false, null: false
      add :app_admin, :boolean, default: false, null: false
      add :default, :boolean, default: false, null: false
      add :description, :text
      add :yard_id, references(:yards, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:roles, [:name, :yard_id], name: :roles_unique_index)
  end
end
