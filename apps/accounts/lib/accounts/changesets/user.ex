defmodule Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

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
    field :first_name, :string
    field :middle_name, :string
    field :last_name, :string
    field :active, :boolean, default: true
    field :it_admin, :boolean, default: false
    field :customer, :boolean, default: false
    field :allow_password_reset, :boolean, default: false
    field :allow_request_app_access, :boolean, default: false
    field :password, :string, virtual: true
    field :password_hash, :string
    field :invitation_token, :string

    timestamps()
  end

  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [
      :username,
      :email,
      :name,
      :first_name,
      :middle_name,
      :last_name,
      :active,
      :it_admin,
      :customer,
      :allow_password_reset,
      :allow_request_app_access,
      :invitation_token])
    |> validate_required([:username])
    |> unique_constraint(:username, name: :users_username_index)
    |> unique_constraint(:email, name: :users_email_index)
    |> format_name()
  end

  def auth_changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:password])
    |> validate_length(:password, min: 6, max: 100)
    |> validate_confirmation(:password)
    |> put_pass_hash()
  end

  def customer_changeset(user, attrs \\ %{}) do
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
    |> put_pass_hash()
  end

  defp format_name(changeset) do
    {_, customer} = fetch_field(changeset, :customer)
    {_, first} = fetch_field(changeset, :first_name)
    first = capitalize_name(first)
    {_, middle} = fetch_field(changeset, :middle_name)
    middle = capitalize_name(middle)
    {_, last} = fetch_field(changeset, :last_name)
    last = capitalize_name(last)
    changeset = change(changeset, %{first_name: first, middle_name: middle, last_name: last})
    {_, username} = fetch_field(changeset, :username)
    cond do
      customer ->
        changeset
      first && middle && last ->
        change(changeset, %{name: "#{last}, #{first} #{middle}"})
      first && last ->
        change(changeset, %{name: "#{last}, #{first}"})
      last ->
        change(changeset, %{name: last})
      true ->
        change(changeset, %{name: username})
    end
  end

  defp capitalize_name(name) do
    cond do
      name -> (name |> String.at(0) |> String.upcase()) <> String.slice(name, 1..-1)
      true -> name
    end
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
