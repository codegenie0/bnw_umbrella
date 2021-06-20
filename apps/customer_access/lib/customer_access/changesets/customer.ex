defmodule CustomerAccess.Customer do
  use Ecto.Schema
  import Ecto.Changeset

  alias CustomerAccess.{
    CustomerReportType,
    ReportType
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
    field :customer, :boolean, default: true
    field :allow_password_reset, :boolean, default: false
    field :allow_request_app_access, :boolean, default: false
    field :password, :string, virtual: true
    field :password_hash, :string
    field :invitation_token, :string
    has_many :customers_report_types, CustomerReportType, foreign_key: :user_id, on_replace: :delete
    many_to_many :report_types, ReportType, join_through: CustomerReportType, join_keys: [user_id: :id, report_type_id: :id]

    timestamps()
  end

  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [
      :username,
      :email,
      :name,
      :active,
      :customer,
      :allow_password_reset,
      :invitation_token,
      :password])
    |> validate_required([:username])
    |> unique_constraint(:username, name: :users_username_index)
    |> unique_constraint(:email, name: :users_email_index)
    |> cast_assoc(:customers_report_types, with: &CustomerReportType.changeset/2)
    |> put_pass_hash()
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Argon2.hash_pwd_salt(pass))
      _ ->
        changeset
    end
  end
end
