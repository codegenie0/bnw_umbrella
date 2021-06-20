defmodule BnwDashboardWeb.Authentication.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :bnw_dashboard_web,
    error_handler: BnwDashboardWeb.Authentication.ErrorHandler,
    module: Accounts.Authenticate

  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
  plug Guardian.Plug.LoadResource, allow_blank: true
end
