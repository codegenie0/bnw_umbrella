defmodule CattlePurchase.Repo do
  use Ecto.Repo,
    otp_app: :cattle_purchase,
    adapter: Ecto.Adapters.MyXQL
end

defmodule CattlePurchase.Repo.Turnkey do
  use Ecto.Repo,
    otp_app: :cattle_purchase,
    adapter: Ecto.Adapters.MyXQL,
    read_only: true
end
