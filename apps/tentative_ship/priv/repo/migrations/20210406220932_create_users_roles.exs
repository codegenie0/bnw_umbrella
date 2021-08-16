defmodule TentativeShip.Repo.Migrations.CreateUsersRoles do
  use Ecto.Migration

  def change do
    create table(:users_roles) do
      add :user_id, references(:users, prefix: user_prefix(Application.get_env(:customer_access, :env)), on_delete: :delete_all, null: false)
      add :role_id, references(:roles, on_delete: :delete_all, null: false)
    end

    create unique_index(:users_roles, [:user_id, :role_id], name: :users_roles_unique_index)
  end

  defp user_prefix(:dev), do: "#{user_prefix()}_dev"
  defp user_prefix(:test), do: "#{user_prefix()}_test"
  defp user_prefix(_), do: user_prefix()
  defp user_prefix(), do: "bnw_dashboard_accounts"
end
