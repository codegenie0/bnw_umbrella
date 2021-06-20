defmodule BorrowingBase.Role do
  use Ecto.Schema
  import Ecto.Changeset

  alias BorrowingBase.Company

  prefix = "bnw_dashboard_borrowing_base"
  prefix = case Application.get_env(:borrowing_base, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end
  @schema_prefix prefix

  schema "roles" do
    field :name, :string
    field :company_admin, :boolean, default: false
    field :app_admin, :boolean, default: false
    belongs_to :company, Company

    timestamps()
  end

  def changeset(yard, attrs \\ %{}) do
    yard
    |> cast(attrs, [:name, :company_id])
    |> validate_required([:name])
    |> unique_constraint(:name, name: :roles_unique_index)
  end
end
