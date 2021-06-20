defmodule PlugsApp.UserRole do
  use Ecto.Schema
  import Ecto.Changeset

  alias PlugsApp.User

  prefix = "bnw_dashboard_plugs_app"
  prefix = case Application.get_env(:accounts, :env) do
             :dev -> prefix <> "_dev"
             :test -> prefix <> "_test"
             _ -> prefix
           end
  @schema_prefix prefix

  schema "users_roles" do
    field :role,  :string
    field :level, :string
    belongs_to :user, User
  end

  def changeset(user_role, attrs \\ %{}) do
    user_role
    |> cast(attrs, [:user_id, :role, :level])
  end
end
