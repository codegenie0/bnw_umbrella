defmodule TentativeShip.Repo.Migrations.CreateSchedulesCustomers do
  use Ecto.Migration

  def change do
    create table(:schedules_customers) do
      add :schedule_id, references(:schedules, on_delete: :delete_all)
      add :customer_id, references(:customers, on_delete: :delete_all)
    end
  end
end
