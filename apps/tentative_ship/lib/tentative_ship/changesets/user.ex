defmodule TentativeShip.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias TentativeShip.{
    Role,
    UserRole
  }

  prefix = "bnw_dashboard_accounts"
  prefix = case Application.get_env(:accounts, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end
  @schema_prefix prefix

  schema "users" do
    field :username, :string
    field :email, :string
    field :name, :string
    field :active, :boolean, default: true
    has_many :users_roles, UserRole, on_replace: :delete
    has_many :roles, through: [:users_roles, :role]
  end

  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [])
    |> cast_assoc(:users_roles, with: &UserRole.changeset/2)
  end
end
