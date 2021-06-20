defmodule ComponentApplications.InternalApplicationsTest do
  use ComponentApplications.DataCase, async: true

  alias ComponentApplications.InternalApplications, as: IntApps

  describe "Internal Applications" do
    test "success: list_internal_applications/0 returns all internal_applications" do
      internal_applications = IntApps.list_internal_applications()
      assert Enum.any?(internal_applications, &(&1.name == "Applications"))
    end

    test "success: get_internal_application/1 returns one internal_application" do
      assert IntApps.get_internal_application("Applications") == %{
        name: "Applications",
        pages: [
          %{name: "External Applications", url: "/applications/external"}
        ]
      }
    end
  end
end
