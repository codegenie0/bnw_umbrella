defmodule BorrowingBase.Repo do
  use Ecto.Repo,
    otp_app: :borrowing_base,
    adapter: Ecto.Adapters.MyXQL
end

defmodule BorrowingBase.Repo.Turnkey do
  use Ecto.Repo,
    otp_app: :borrowing_base,
    adapter: Ecto.Adapters.MyXQL,
    read_only: true
end

defmodule BorrowingBase.Repo.InformationSchema do
  use Ecto.Repo,
    otp_app: :borrowing_base,
    adapter: Ecto.Adapters.MyXQL,
    read_only: true
end
