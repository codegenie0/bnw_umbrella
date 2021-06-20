defmodule Reimbursement.Repo.Migrations.CreateReportUrl do
  use Ecto.Migration

  def change do
    create table(:report_url) do
      add :url,     :string, size: 512
      add :name,    :string, size: 32
      add :active,  :boolean
      add :primary, :boolean
    end
  end
end
