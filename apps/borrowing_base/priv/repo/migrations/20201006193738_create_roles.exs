defmodule BorrowingBase.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :name, :string, null: false
      add :company_admin, :boolean, default: false, null: false
      add :app_admin, :boolean, default: false, null: false
      add :company_id, references(:companies, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:roles, [:name, :company_id], name: :roles_unique_index)
  end
end
