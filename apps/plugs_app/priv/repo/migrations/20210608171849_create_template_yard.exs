defmodule PlugsApp.Repo.Migrations.CreateTemplateYard do
  use Ecto.Migration

  def change do
    create table(:template_yard) do
      add :yard, :string

      timestamps()
    end

    create unique_index(:template_yard, :yard, name: :template_yard_unique_constraint)
  end
end
