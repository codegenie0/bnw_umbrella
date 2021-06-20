defmodule Reimbursement.Repo do
  use Ecto.Repo,
    otp_app: :reimbursement,
    adapter: Ecto.Adapters.MyXQL
end
