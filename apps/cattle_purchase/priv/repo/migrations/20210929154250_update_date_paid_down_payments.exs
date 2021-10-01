defmodule CattlePurchase.Repo.Migrations.UpdateDatePaidDownPayments do
  use Ecto.Migration

  def change do
    alter table(:down_payments) do
      modify :date_paid, :date
    end
  end
end
