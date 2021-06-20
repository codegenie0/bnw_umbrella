defmodule Accounts.TestHelpers do
  alias Accounts.User
  alias Accounts.Users

  def user_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        username: "testuser",
        email: "testuser@beefnw.com",
        name: "Test User",
        first_name: "Test",
        middle_name: "Middle",
        last_name: "User",
        active: true,
        it_admin: false,
        allow_password_reset: true
      })

    {:ok, user} = Users.create_or_update_user(%User{}, attrs)

    user
  end
end
