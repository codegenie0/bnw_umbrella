defmodule PlugsApp.Repo.Migrations.CreateUsersRoles do
  use Ecto.Migration

  def change do
    create table(:users_roles) do
      add :user_id, references(:users, prefix: user_prefix(Application.get_env(:reimbursement, :env)), on_delete: :delete_all, null: false)
      add :role,  :string
      add :level, :string

      timestamps()
    end
  end

  defp user_prefix(:dev), do: "#{user_prefix()}_dev"
  defp user_prefix(:test), do: "#{user_prefix()}_test"
  defp user_prefix(_), do: user_prefix()
  defp user_prefix(), do: "bnw_dashboard_accounts"
end
