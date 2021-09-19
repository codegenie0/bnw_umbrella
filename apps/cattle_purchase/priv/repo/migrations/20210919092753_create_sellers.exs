defmodule CattlePurchase.Repo.Migrations.CreateSellers do
  use Ecto.Migration

  def change do
    create table(:sellers) do
      add :state_id, references(:states, null: false)
      add :purchase_id, references(:purchases)
      add :producer, :string, null: false
      add :seller_location, :string, null: false
      add :origin_code, :string
      add :latitude, :decimal, precision: 10, scale: 8
      add :longitude, :decimal, precision: 10, scale: 8
      add :description, :text
      add :active, :boolean, default: false, null: false


      timestamps()
    end
  end
end
