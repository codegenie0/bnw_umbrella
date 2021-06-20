defmodule ComponentApplications.InternalApplications do
  @moduledoc """
  Handles getting info for all internal applications.
  """

  @doc """
  Returns info on one app.

  ## Examples

    iex> get_internal_application("applications")
    %{name: "Applications"}, pages: [%{name: "external", url: "/applications/external"}, ...]

  """
  def get_internal_application(name) do
    list_internal_applications()
    |> Enum.find(&(String.downcase(&1.name) == String.downcase(name)))
  end

  @doc """
  Returns info on all apps. Calls each app's get_pages()/0 which expects a list
  of the app's pages in the form of [%{name: "Example", url: "/app/example"}, ...]

  ## Examples

    iex> list_internal_application()
    [%{name: "Applications"}, pages: [%{name: "external", url: "/applications/external"}, ...]]

  """
  def list_internal_applications() do
    [
      %{name: "Accounts",         pages: Accounts.Pages.list_pages()},
      %{name: "Applications",     pages: ComponentApplications.Pages.list_pages()},
      %{name: "Cattle Purchase",  pages: CattlePurchase.Pages.list_pages()},
      %{name: "Customer Access",  pages: CustomerAccess.Pages.list_pages()},
      %{name: "Borrowing Base",   pages: BorrowingBase.Pages.list_pages()},
      %{name: "CIH Report Plugs", pages: CihReportPlugs.Pages.list_pages()},
      %{name: "OCB Report Plugs", pages: OcbReportPlugs.Pages.list_pages()},
      %{name: "Plugs",            pages: PlugsApp.Pages.list_pages()},
      %{name: "Reimbursement",    pages: Reimbursement.Pages.list_pages()}
    ]
  end
end
