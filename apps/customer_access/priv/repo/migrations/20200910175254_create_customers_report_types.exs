defmodule CustomerAccess.Repo.Migrations.CreateCustomersReportTypes do
  use Ecto.Migration

  def change do
    create table(:customers_report_types) do
      add :user_id, references(:users, prefix: user_prefix(Application.get_env(:customer_access, :env)), on_delete: :delete_all, null: false)
      add :report_type_id, references(:report_types, on_delete: :delete_all, null: false)
    end

    create unique_index(:customers_report_types, [:user_id, :report_type_id], name: :customers_report_types_unique_index)
  end

  defp user_prefix(:dev), do: "#{user_prefix()}_dev"
  defp user_prefix(:test), do: "#{user_prefix()}_test"
  defp user_prefix(_), do: user_prefix()
  defp user_prefix(), do: "bnw_dashboard_accounts"
end
