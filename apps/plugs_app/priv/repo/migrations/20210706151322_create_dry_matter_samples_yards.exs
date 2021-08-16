defmodule PlugsApp.Repo.Migrations.CreateDryMatterSamplesYards do
  use Ecto.Migration

  def change do
    create table(:dry_matter_samples_yards) do
      add :yard, :string

      timestamps()
    end
    create unique_index(:dry_matter_samples_yards, :yard, name: :dry_matter_samples_yard_unique_constraint)
  end
end
