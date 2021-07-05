defmodule CattlePurchase.Repo.Migrations.RemoveExtraFieldsFromDestinationGroups do
  use Ecto.Migration

  def change do
    alter table("destination_groups") do
      remove :lft
      remove :rgt
    end
  end
end
