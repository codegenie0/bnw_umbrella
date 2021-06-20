defmodule BorrowingBase.Repo.Migrations.CreateRolesYards do
  use Ecto.Migration

  def change do
    create table(:roles_yards) do
      add :role_id, references(:roles, on_delete: :delete_all)
      add :yard_id, references(:yards, on_delete: :delete_all)
    end

    create unique_index(:roles_yards, [:role_id, :yard_id], name: :roles_yards_unique_index)
  end
end
