defmodule TentativeShip.RolePermission do
  use Ecto.Schema
  import Ecto.Changeset

  alias TentativeShip.{
    Permission,
    Role
  }

  prefix = "bnw_dashboard_tentative_ship"
  prefix = case Mix.env do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end
  @schema_prefix prefix

  schema "roles_permissions" do
    belongs_to :permission, Permission
    belongs_to :role, Role
  end

  def changeset(role_permission, attrs \\ %{}) do
    role_permission
    |> cast(attrs, [:permission_id, :role_id])
  end
end
