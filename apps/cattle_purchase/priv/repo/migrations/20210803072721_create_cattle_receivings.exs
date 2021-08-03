defmodule CattlePurchase.Repo.Migrations.CreateCattleReceivings do
  use Ecto.Migration

  def change do
    create table(:cattle_receivings) do
      add :user_id, references(:users, prefix: user_prefix(Application.get_env(:cattle_purchase, :env)), on_delete: :delete_all, null: false)
      add :number_received, :integer, null: false
      add :comment, :text
      add :sex_id, references(:sexes)
      add :shipment_id, references(:shipments, null: false)
      add :lot_number, :string, null: false
      add :off_truck_weight, :integer, null: false
      add :pay_weight, :integer, null: false
      add :date_received, :date, null: false
      add :wcc_notification, :boolean, default: false
      add :receive_override, :boolean, default: false
      add :flow_to_purchase_sheet, :boolean, default: false

      timestamps()
    end
  end

  defp user_prefix(:dev), do: "#{user_prefix()}_dev"
  defp user_prefix(:test), do: "#{user_prefix()}_test"
  defp user_prefix(_), do: user_prefix()
  defp user_prefix(), do: "bnw_dashboard_accounts"
end
