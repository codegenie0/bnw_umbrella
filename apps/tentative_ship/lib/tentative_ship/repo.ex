defmodule TentativeShip.Repo do
  use Ecto.Repo,
    otp_app: :tentative_ship,
    adapter: Ecto.Adapters.MyXQL
end
