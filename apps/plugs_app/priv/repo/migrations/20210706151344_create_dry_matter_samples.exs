defmodule PlugsApp.Repo.Migrations.CreateDryMatterSamples do
  use Ecto.Migration

  def change do
    create table(:dry_matter_samples) do
      add :yard,        :integer, null: false
      add :item,        :integer, null: false
      add :sample_date, :date
      add :pan,         :decimal, precision: 12, scale: 2, default: 0.00
      add :wet,         :decimal, precision: 12, scale: 2, default: 0.00
      add :dry,         :decimal, precision: 12, scale: 2, default: 0.00
      add :target_dm,   :decimal, precision: 12, scale: 2, default: 0.00

      timestamps()
    end

    create unique_index(:dry_matter_samples, [
          :yard,
          :item,
          :sample_date,
        ],
        name: :dms_unique_key)
  end
end
