defmodule ComponentApplications.TestHelpers do
  alias ComponentApplications.ExternalApplication, as: ExApp
  alias ComponentApplications.ExternalApplications, as: ExApps

  def external_application_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "Beef Northwest Home",
        url: "http://home.beefnw.com"
      })

    {:ok, external_application} =
      ExApps.create_or_update_external_application(%ExApp{}, attrs)

    external_application
  end
end
