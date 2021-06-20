defmodule ComponentApplications.Authorize do
  alias Accounts.User
  alias ComponentApplications.{
    ExternalApplications,
    InternalApplications
  }

  def list_pages(%User{} = user) do
    internal_applications = InternalApplications.list_internal_applications()
    external_applications = ExternalApplications.list_external_applications()

    cond do
      user.it_admin ->
        %{
          internal_applications: internal_applications,
          external_applications: external_applications
        }
      true ->
        internal_applications = [] ++
          CustomerAccess.Authorize.list_pages(user, internal_applications) ++
          Reimbursement.Authorize.list_pages(user, internal_applications) ++
          CustomerAccess.Authorize.list_pages(user, internal_applications) ++
          BorrowingBase.Authorize.list_pages(user, internal_applications) ++
          CihReportPlugs.Authorize.list_pages(user, internal_applications) ++
          PlugsApp.Authorize.list_pages(user, internal_applications) ++
          OcbReportPlugs.Authorize.list_pages(user, internal_applications)

        external_applications = []
        %{internal_applications: internal_applications, external_applications: external_applications}
    end
  end

  def check_authorization(%User{} = user, page) do
    cond do
      user.it_admin ->
        {:ok, page}
      true ->
        {:error, page}
    end
  end
end
