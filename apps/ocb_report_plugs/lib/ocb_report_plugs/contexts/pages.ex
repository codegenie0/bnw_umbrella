defmodule OcbReportPlugs.Pages do
  def list_pages() do
    [
      %{name: "Plugs", url: "/ocb/plugs"},
      %{name: "Users", url: "/ocb/users"}
    ]
  end
end
