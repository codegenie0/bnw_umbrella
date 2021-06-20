defmodule BorrowingBase.Repo.Migrations.CreateEffectiveDates do
  use Ecto.Migration

  def change do
    create table(:effective_dates) do
      add :effective_date, :date, null: false
      add :locked, :boolean, default: false, null: false
      add :weight_break_id, references(:weight_breaks, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:effective_dates, [:effective_date, :weight_break_id], name: :effective_dates_unique_index)
  end
end
