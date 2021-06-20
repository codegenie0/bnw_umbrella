defmodule Reimbursement.Repo.Migrations.CreateReimbursementEntry do
  use Ecto.Migration

  def change do
    create table(:reimbursement_entry) do
      add :user_id,
        references(:users,
                   prefix: user_prefix(Application.get_env(:reimbursement, :env)),
                   on_delete: :delete_all,
                   null: false)
      add :desc,         :string
      add :entry_date,   :date
      add :radio,        :integer, default: 1
      add :start_mileage,:decimal, precision: 12, scale: 2, default: 0.00,  null: 0.00
      add :end_mileage,  :decimal, precision: 12, scale: 2, default: 0.00,  null: 0.00
      add :mileage,      :decimal, precision: 12, scale: 2, default: 0.00,  null: 0.00
      add :rate,         :decimal, precision: 12, scale: 3, default: 0.000, null: 0.000
      add :amount,       :decimal, precision: 12, scale: 2, default: 0.00,  null: 0.00
      add :misc_amount,  :decimal, precision: 12, scale: 2, default: 0.00,  null: 0.00
      add :amount_tot,   :decimal, precision: 12, scale: 2, default: 0.00,  null: 0.00
    end
  end

  defp user_prefix(:dev), do: "#{user_prefix()}_dev"
  defp user_prefix(:test), do: "#{user_prefix()}_test"
  defp user_prefix(_), do: user_prefix()
  defp user_prefix(), do: "bnw_dashboard_accounts"
end
