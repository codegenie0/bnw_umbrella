defmodule TentativeShip.Repo.Migrations.CreateSchedulesSexCodes do
  use Ecto.Migration

  def change do
    create table(:schedules_sex_codes) do
      add :schedule_id, references(:schedules, on_delete: :delete_all)
      add :sex_code_id, references(:sex_codes, on_delete: :delete_all)
    end
  end
end
