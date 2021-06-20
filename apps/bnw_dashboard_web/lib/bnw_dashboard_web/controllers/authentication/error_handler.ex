defmodule BnwDashboardWeb.Authentication.ErrorHandler do
  use BnwDashboardWeb, :controller

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, _reason, _opts) do
    redirect(conn, to: Routes.auth_path(conn, :request))
  end
end
