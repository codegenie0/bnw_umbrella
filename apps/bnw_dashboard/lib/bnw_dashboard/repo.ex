defmodule BnwDashboard.Repo do
  use Ecto.Repo,
    otp_app: :bnw_dashboard,
    adapter: Ecto.Adapters.MyXQL
end
