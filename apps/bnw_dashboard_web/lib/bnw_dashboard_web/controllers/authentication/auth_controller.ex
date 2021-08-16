defmodule BnwDashboardWeb.AuthController do
  @moduledoc """
  Controller responsible for handling Ueberauth responses
  """
  use BnwDashboardWeb, :controller
  plug Ueberauth

  alias Ueberauth.Strategy.Helpers
  alias Accounts.{Authenticate, Users, User}

  def request(conn, _params) do
    if Authenticate.Plug.current_resource(conn) do
      render(conn, "/")
    else
      changeset = Authenticate.change_user()
      render(conn, "request.html", callback_url: Helpers.callback_url(conn), changeset: changeset)
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:success, "You have successfully logged out!")
    |> Authenticate.Plug.sign_out()
    |> redirect(to: Routes.auth_path(conn, :request))
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: Routes.auth_path(conn, :request))
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case Authenticate.authenticate(auth) do
      {:ok, user} ->
        conn
        |> put_session(:live_socket_id, "users_socket:#{user.id}")
        |> Authenticate.Plug.sign_in(user)
        |> redirect(to: "/")
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.auth_path(conn, :request))
    end
  end

  def reset_password(conn, %{"token" => token}) do
    with {:ok, user_id} <- Phoenix.Token.verify(BnwDashboardWeb.Endpoint, System.get_env("PASSWORD_RESET_SALT"), token, max_age: (60 * 60)),
         %User{active: true, allow_password_reset: true} = user <- Users.get_user!(user_id) do
      changeset = Authenticate.change_user(user)
      render(conn, "set_password.html", changeset: changeset, token: token)
    else
      _ ->
        conn
        |> put_flash(:error, "Password reset link expired.")
        |> redirect(to: Routes.auth_path(conn, :request))
    end
  end

  def reset_password(conn, %{"user" => user_params}) do
    with {:ok, user_id} <- Phoenix.Token.verify(BnwDashboardWeb.Endpoint, System.get_env("PASSWORD_RESET_SALT"), Map.get(user_params, "token"), max_age: (60 * 60)),
         %User{active: true, allow_password_reset: true} = user <- Users.get_user!(user_id) do
      changeset = Authenticate.change_user(user, user_params)
      cond do
        changeset.valid? ->
          Authenticate.update_user(user, user_params)
          conn
          |> put_flash(:success, "Password reset.")
          |> redirect(to: Routes.auth_path(conn, :request))
        true ->
          changeset = Map.put(changeset, :action, :update)
          render(conn, "set_password.html", changeset: changeset, token: Map.get(user_params, "token"))
      end
    else
      _ ->
        conn
        |> put_flash(:error, "Password reset link expired.")
        |> redirect(to: Routes.auth_path(conn, :request))
    end
  end

  def reset_password(conn, %{"credential" => credential}) do
    {result, user} = Authenticate.password_reset_check(credential)

    if result == :ok do
      token = Phoenix.Token.sign(BnwDashboardWeb.Endpoint, System.get_env("PASSWORD_RESET_SALT"), user.id)
      reset_url = Routes.auth_url(conn, :reset_password, token: token)

      BnwDashboardWeb.Email.reset_password_email(user, reset_url)
      |> BnwDashboardWeb.Mailer.deliver_later
    end

    conn
    |> put_flash(:info, "Please check for an email with instructions on how to change your password.")
    |> redirect(to: Routes.auth_path(conn, :request))
  end

  def reset_password(conn, _params) do
    render(conn, "reset_password.html")
  end
end
