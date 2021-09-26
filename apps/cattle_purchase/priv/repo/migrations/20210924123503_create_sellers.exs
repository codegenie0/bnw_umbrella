defmodule CattlePurchase.Repo.Migrations.CreateSellers do
  use Ecto.Migration

  def change do
    create table(:sellers) do
      add :state_id, references(:states, null: false)
      add :producer, :string, null: false
      add :seller_location, :string, null: false
      add :origin_code, :string
      add :latitude, :decimal, precision: 10, scale: 6
      add :longitude, :decimal, precision: 10, scale: 6
      add :description, :text
      add :active, :boolean, default: false, null: false


      timestamps()
    end
  end
end
