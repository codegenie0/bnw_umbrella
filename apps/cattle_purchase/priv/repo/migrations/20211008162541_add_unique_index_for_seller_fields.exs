defmodule CattlePurchase.Repo.Migrations.AddUniqueIndexForSellerFields do
  use Ecto.Migration

  def change do
    create unique_index(:sellers, [:producer, :seller_location, :state_id], name: :prducer_seller_location_state_id_unique_index)

  end
end
