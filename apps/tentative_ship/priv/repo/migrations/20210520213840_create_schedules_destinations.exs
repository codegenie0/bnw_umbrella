defmodule TentativeShip.Repo.Migrations.CreateSchedulesDestinations do
  use Ecto.Migration

  def change do
    create table(:schedules_destinations) do
      add :schedule_id, references(:schedules, on_delete: :delete_all)
      add :destination_id, references(:destinations, on_delete: :delete_all)
    end
  end
end
