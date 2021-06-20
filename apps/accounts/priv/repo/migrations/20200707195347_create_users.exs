defmodule Accounts.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string, null: false
      add :email, :string
      add :name, :string
      add :first_name, :string
      add :middle_name, :string
      add :last_name, :string
      add :active, :boolean, default: true, null: false
      add :it_admin, :boolean, default: false, null: false
      add :allow_password_reset, :boolean, default: false, null: false
      add :allow_request_app_access, :boolean, default: false, null: false
      add :customer, :boolean, default: false, null: false
      add :password_hash, :string
      add :invitation_token, :string

      timestamps()
    end

    create unique_index(:users, [:username])
    create unique_index(:users, [:email])
    create unique_index(:users, [:invitation_token])
  end
end
