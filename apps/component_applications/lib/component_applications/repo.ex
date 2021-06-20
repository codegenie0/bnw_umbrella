defmodule ComponentApplications.Repo do
  use Ecto.Repo,
    otp_app: :component_applications,
    adapter: Ecto.Adapters.MyXQL
end
