defmodule TentativeShip.Repo.Migrations.CreateSchedulesLotStatusCodes do
  use Ecto.Migration

  def change do
    create table(:schedules_lot_status_codes) do
      add :schedule_id, references(:schedules, on_delete: :delete_all)
      add :lot_status_code_id, references(:lot_status_codes, on_delete: :delete_all)
    end
  end
end
