defmodule CattlePurchase.Repo.Migrations.AddOffsetToSexes do
  use Ecto.Migration

  def change do
    alter table("sexes") do
      add :offset, :integer
    end
  end
end
