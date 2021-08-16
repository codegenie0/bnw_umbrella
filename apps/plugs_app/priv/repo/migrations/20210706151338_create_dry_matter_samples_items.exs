defmodule PlugsApp.Repo.Migrations.CreateDryMatterSamplesItems do
  use Ecto.Migration

  def change do
    create table(:dry_matter_samples_items) do
      add :yard, :integer, null: false
      add :item, :string

      timestamps()
    end

    create unique_index(:dry_matter_samples_items, [:yard, :item], name: :dms_items_unique_key)
  end
end
