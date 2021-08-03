defmodule CattlePurchase.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias CattlePurchase.{UserRole, CattleReceiving}

  prefix = "bnw_dashboard_accounts"

  prefix =
    case Application.get_env(:accounts, :env) do
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

    has_many(:cattle_receivings, CattleReceiving)
    has_many :users_roles, UserRole, on_replace: :delete
  end

  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [])
    |> cast_assoc(:users_roles, with: &UserRole.changeset/2)
  end
end
