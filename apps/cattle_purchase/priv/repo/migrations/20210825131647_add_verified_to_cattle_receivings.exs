defmodule CattlePurchase.Repo.Migrations.AddVerifiedToCattleReceivings do
  use Ecto.Migration

  def change do
    alter table(:cattle_receivings) do
      add :verified, :boolean, default: false
    end
  end
end
