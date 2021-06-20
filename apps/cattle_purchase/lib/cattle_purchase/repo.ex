defmodule CattlePurchase.Repo do
  use Ecto.Repo,
    otp_app: :cattle_purchase,
    adapter: Ecto.Adapters.MyXQL
end
