defmodule CihReportPlugs.Repo do
  use Ecto.Repo,
    otp_app: :cih_report_plugs,
    adapter: Ecto.Adapters.MyXQL
end
