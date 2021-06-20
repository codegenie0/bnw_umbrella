defmodule BorrowingBase.UserRole do
  use Ecto.Schema
  import Ecto.Changeset

  alias BorrowingBase.{
    Role,
    User
  }

  prefix = "bnw_dashboard_borrowing_base"
  prefix = case Application.get_env(:borrowing_base, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end
  @schema_prefix prefix

  schema "users_roles" do
    belongs_to :role, Role
    belongs_to :user, User
  end

  def changeset(user_role, attrs \\ %{}) do
    user_role
    |> cast(attrs, [:user_id, :role_id])
  end
end
