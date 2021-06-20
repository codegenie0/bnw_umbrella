defmodule ComponentApplications.ExternalApplicationsTest do
  use ComponentApplications.DataCase, async: true

  alias ComponentApplications.ExternalApplication, as: ExApp
  alias ComponentApplications.ExternalApplications, as: ExApps

  describe "normal crud" do
    @valid_attrs %{
      name: "Beef Northwest Home",
      url: "http://home.beefnw.com"
    }
    @invalid_attrs %{}

    test "success: list_external_applications/0 returns all external_applications" do
      %ExApp{id: id1} = external_application_fixture()
      assert [%ExApp{id: ^id1}] = ExApps.list_external_applications()
      %ExApp{id: id2} = external_application_fixture(%{name: "test", url: "http://test.beefnw.com"})
      assert [%ExApp{id: ^id1}, %ExApp{id: ^id2}] = ExApps.list_external_applications()
    end

    test "success: get_external_application!/1 returns the external_application with given id" do
      %ExApp{id: id} = external_application_fixture()
      assert %ExApp{id: ^id} = ExApps.get_external_application!(id)
    end

    test "success: create_or_update_external_application/2 with valid data creates an external_application" do
      assert {:ok, %ExApp{id: id} = app} = ExApps.create_or_update_external_application(%ExApp{}, @valid_attrs)
      assert app.name == "Beef Northwest Home"
      assert app.url == "http://home.beefnw.com"
      assert [%ExApp{id: ^id}] = ExApps.list_external_applications()
    end

    test "error: create_or_update_external_application/2 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ExApps.create_or_update_external_application(%ExApp{}, @invalid_attrs)
    end

    test "success: create_or_update_external_application/2 with valid data updates the external_application" do
      external_application = external_application_fixture()
      assert {:ok, external_application} = ExApps.create_or_update_external_application(external_application, %{name: "updated name"})
      assert %ExApp{} = external_application
      assert external_application.name == "updated name"
    end

    test "error: create_or_update_external_application/2 with invalid data returns error changeset for update" do
      %ExApp{id: id} = external_application = external_application_fixture()
      assert {:error, %Ecto.Changeset{}} = ExApps.create_or_update_external_application(external_application, %{name: nil, url: nil})
      assert %ExApp{id: ^id} = ExApps.get_external_application!(id)
    end

    test "success: delete_external_application/1 deletes the external_application" do
      external_application = external_application_fixture()
      assert {:ok, %ExApp{}} = ExApps.delete_external_application(external_application)
      assert ExApps.list_external_applications() == []
    end

    test "success: change_external_application/1 returns an external_application changeset" do
      external_application = external_application_fixture()
      assert %Ecto.Changeset{} = ExApps.change_external_application(external_application)
    end
  end
end
