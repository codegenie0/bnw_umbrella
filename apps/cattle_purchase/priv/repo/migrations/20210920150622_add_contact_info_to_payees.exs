defmodule CattlePurchase.Repo.Migrations.AddContactInfoToPayees do
  use Ecto.Migration

  def change do
    alter table(:payees) do
      add :address1, :string
      add :address2, :string
      add :city, :string
      add :state, :string
      add :zip, :string
      add :phone, :string
      add :contact_name, :string
      add :comments, :string
    end
  end
end
