defmodule TentativeShip.Role do
  use Ecto.Schema
  import Ecto.Changeset

  alias TentativeShip.{
    Permission,
    RolePermission,
    Yard
  }

  prefix = "bnw_dashboard_tentative_ship"
  prefix = case Mix.env do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end
  @schema_prefix prefix

  schema "roles" do
    field :name, :string
    field :yard_admin, :boolean, default: false
    field :app_admin, :boolean, default: false
    field :default, :boolean, default: false
    field :description, :string
    belongs_to :yard, Yard
    belongs_to :default_role, __MODULE__
    has_many :yard_roles, __MODULE__, foreign_key: :default_role_id
    has_many :role_permissions, RolePermission, on_replace: :delete
    many_to_many :permissions, Permission, join_through: RolePermission

    timestamps()
  end

  def changeset(role, params \\ %{}) do
    role
    |> cast(params, [
      :name,
      :yard_admin,
      :app_admin,
      :default,
      :description,
      :yard_id,
      :default_role_id])
    |> validate_required([:name])
    |> unique_constraint(:name, name: :roles_unique_index)
    |> cast_assoc(:role_permissions, with: &RolePermission.changeset/2)
  end
end
