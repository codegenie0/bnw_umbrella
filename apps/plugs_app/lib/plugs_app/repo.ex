defmodule PlugsApp.Repo do
  use Ecto.Repo,
    otp_app: :plugs_app,
    adapter: Ecto.Adapters.MyXQL
end
