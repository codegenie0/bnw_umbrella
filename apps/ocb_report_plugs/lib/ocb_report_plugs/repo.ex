defmodule OcbReportPlugs.Repo do
  use Ecto.Repo,
    otp_app: :ocb_report_plugs,
    adapter: Ecto.Adapters.MyXQL
end
