defmodule TentativeShip.Repo.Migrations.CreateSchedulesYardNumbers do
  use Ecto.Migration

  def change do
    create table(:schedules_yard_numbers) do
      add :schedule_id, references(:schedules, on_delete: :delete_all)
      add :yard_number_id, references(:yard_numbers, on_delete: :delete_all)
    end
  end
end
