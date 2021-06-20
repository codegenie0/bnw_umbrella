defmodule CihReportPlugs.Pages do
  def list_pages() do
    [
      %{name: "Plugs", url: "/cih/plugs"},
      %{name: "Users", url: "/cih/users"}
    ]
  end
end
