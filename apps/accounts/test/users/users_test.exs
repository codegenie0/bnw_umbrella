defmodule Accounts.UsersTest do
  use Accounts.DataCase, async: true

  alias Accounts.User
  alias Accounts.Users

  describe "normal crud" do
    @valid_attrs %{
      username: "George Burdell",
      email: "george.burdell@beefnw.com",
      name: "George P. Burdell",
      first_name: "George",
      middle_name: "P.",
      last_name: "Burdell",
      active: true,
      it_admin: false,
      allow_password_reset: true
    }
    @invalid_attrs %{}

    test "success: list_users/0 returns all users" do
      %User{id: id1} = user_fixture()
      assert [%User{id: ^id1}] = Users.list_users()
      %User{id: id2} = user_fixture(@valid_attrs)
      assert [%User{id: ^id2}, %User{id: ^id1}] = Users.list_users()
    end

    test "success: get_user!/1 returns the user with given id" do
      %User{id: id} = user_fixture()
      assert %User{id: ^id} = Users.get_user!(id)
    end

    test "success: create_or_update_user/2 with valid data creates a user" do
      assert {:ok, %User{id: id} = user} = Users.create_or_update_user(%User{}, @valid_attrs)
      assert user.username == "George Burdell"
      assert [%User{id: ^id}] = Users.list_users()
    end

    test "error: create_or_update_user/2 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_or_update_user(%User{}, @invalid_attrs)
    end

    test "success: create_or_update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Users.create_or_update_user(user, %{name: "updated name"})
      assert %User{} = user
      assert user.name == "User, Test Middle"
    end

    test "error: create_or_update_user/2 with invalid data returns error changeset for update" do
      %User{id: id} = user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Users.create_or_update_user(user, %{username: nil})
      assert %User{id: ^id} = Users.get_user!(id)
    end

    test "success: delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Users.delete_user(user)
      assert Users.list_users() == []
    end

    test "success: change_user/1 returns an user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Users.change_user(user)
    end
  end
end
