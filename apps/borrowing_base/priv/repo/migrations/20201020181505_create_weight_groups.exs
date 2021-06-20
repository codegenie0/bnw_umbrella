defmodule BorrowingBase.Repo.Migrations.CreateWeightGroups do
  use Ecto.Migration

  def change do
    create table(:weight_groups) do
      add :min_weight, :integer, null: false
      add :max_weight, :integer
      add :yard_id, references(:yards, on_delete: :delete_all)
      add :effective_date_id, references(:effective_dates, on_delete: :delete_all)
      add :weight_break_id, references(:weight_breaks, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:weight_groups, [:min_weight, :max_weight, :yard_id, :effective_date_id], name: :weight_groups_unique_index)
  end
end
