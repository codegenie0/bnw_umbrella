defmodule TentativeShip.Repo do
  use Ecto.Repo,
    otp_app: :tentative_ship,
    adapter: Ecto.Adapters.MyXQL
end

defmodule TentativeShip.Repo.Turnkey do
  use Ecto.Repo,
    otp_app: :tentative_ship,
    adapter: Ecto.Adapters.MyXQL,
    read_only: true
end

defmodule TentativeShip.Repo.CattlePurchase do
  use Ecto.Repo,
    otp_app: :tentative_ship,
    adapter: Ecto.Adapters.MyXQL,
    read_only: true
end

defmodule TentativeShip.Repo.Microbeef do
  use Ecto.Repo,
    otp_app: :tentative_ship,
    adapter: Ecto.Adapters.MyXQL,
    read_only: true
end
