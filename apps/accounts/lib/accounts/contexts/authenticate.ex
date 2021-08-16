defmodule Accounts.Authenticate do
  use Guardian, otp_app: :bnw_dashboard_web

  alias Accounts.{
    Repo,
    User,
    Users
  }

  def authenticate(auth) do
    user = cond do
      auth.provider == :identity ->
        user_info = Map.get(auth.extra.raw_info, "user")
        user = Users.get_user_by(:username, Map.get(user_info, "username"))

        cond do
          user && Argon2.verify_pass(Map.get(user_info, "password"), user.password_hash) ->
            user
          true -> nil
        end
      true ->
        Users.get_user_by(:email, auth.info.email)
    end

    if user && user.active do
      {:ok, user}
    else
      {:error, "Could not sign in with the given credentials"}
    end
  end

  def subject_for_token(%{id: id}, _claims) do
    {:ok, to_string(id)}
  end
  def subject_for_token(_, _), do: {:error, :reason_for_error}

  def resource_from_claims(%{"sub" => id}) do
    case Users.get_user(id) do
      nil -> {:error, :resource_not_found}
      user -> {:ok, user}
    end
  end
  def resource_from_claims(_claims), do: {:error, :reason_for_error}

  def change_user(), do: User.auth_changeset(%User{})

  def change_user(%User{} = user, attrs \\ %{}), do: User.auth_changeset(user, attrs)

  def password_reset_check(credential) do
    user = Users.get_user_by(:username, credential)
    user = cond do
      user -> user
      true -> Users.get_user_by(:email, credential)
    end

    cond do
      user && user.active && user.allow_password_reset -> {:ok, user}
      true -> {:error, :password_reset_unavailable}
    end
  end

  def update_user(%User{} = user, attrs \\ %{}) do
    user
    |> User.auth_changeset(attrs)
    |> Repo.update()
  end
end
