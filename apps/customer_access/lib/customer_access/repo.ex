defmodule CustomerAccess.Repo do
  use Ecto.Repo,
    otp_app: :customer_access,
    adapter: Ecto.Adapters.MyXQL
end

defmodule CustomerAccess.Repo.Turnkey do
  use Ecto.Repo,
    otp_app: :customer_access,
    adapter: Ecto.Adapters.MyXQL,
    read_only: true
end
