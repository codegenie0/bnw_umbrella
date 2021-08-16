defmodule TentativeShip.Repo.Migrations.AddDefaultRoleIdToRoles do
  use Ecto.Migration

  def change do
    alter table(:roles) do
      add :default_role_id, references(:roles, on_delete: :delete_all), after: :yard_id
    end
  end
end
