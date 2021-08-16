defmodule TentativeShip.Repo.Migrations.CreateRolesPermissions do
  use Ecto.Migration

  def change do
    create table(:roles_permissions) do
      add :role_id, references(:roles, on_delete: :delete_all)
      add :permission_id, references(:permissions, on_delete: :delete_all)
    end
  end
end
