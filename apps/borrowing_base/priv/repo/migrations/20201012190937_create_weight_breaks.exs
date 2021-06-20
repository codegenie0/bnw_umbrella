defmodule BorrowingBase.Repo.Migrations.CreateWeightBreaks do
  use Ecto.Migration

  def change do
    create table(:weight_breaks) do
      add :name, :string, null: false
      add :company_id, references(:companies, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:weight_breaks, [:name, :company_id], name: :weight_breaks_unique_index)
  end
end
