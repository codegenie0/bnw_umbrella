defmodule Reimbursement.Roles do
  def list_roles() do
    [
      %{name: "admin",    desc: "An Admin has almost full control of the application.
Exceptions:
      An Admin cannot create or modify Reports.
      An Admin cannot set or remove a User as being an Admin."},
      %{name: "reviewer", desc: "A user can be assigned to a Reviewer.
      Reviewers have access to the Review page.
      Note: it is expected that a Reviewer is also a User."},
      %{name: "report",   desc: "The Report role allows users to access the reports page.
      Note: it is expected that someone with Report access is also a user"},
      %{name: "user",     desc: "General application user.
This permission grants a user access to the entries page.
This permission is required for a reviewer to be able to see the user."},
      %{name: "active",   desc: "this is active"}
    ]
  end
end
