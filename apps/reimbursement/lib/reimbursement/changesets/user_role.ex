defmodule Reimbursement.UserRole do
  use Ecto.Schema
  import Ecto.Changeset

  alias Reimbursement.User

  prefix = "bnw_dashboard_reimbursement"
  prefix = case Application.get_env(:accounts, :env) do
             :dev -> prefix <> "_dev"
             :test -> prefix <> "_test"
             _ -> prefix
           end
  @schema_prefix prefix

  schema "users_roles" do
    field :role, :string
    field :reviewer_id, :integer
    belongs_to :user, User
  end

  def changeset(user_role, attrs \\ %{}) do
   user_role
    |> cast(attrs, [:role, :reviewer_id])
  end
end
