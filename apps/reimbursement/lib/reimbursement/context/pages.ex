defmodule Reimbursement.Pages do
  def list_pages() do
    [
      %{name: "Entries", url: "/reimbursement/entries"},
      %{name: "Review",  url: "/reimbursement/review"},
      %{name: "Rates",   url: "/reimbursement/rates"},
      %{name: "Users",   url: "/reimbursement/users"},
      %{name: "Reports", url: "/reimbursement/reports"},
      %{name: "Help",    url: "/reimbursement/help"}
    ]
  end
end
