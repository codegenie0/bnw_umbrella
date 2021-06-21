defmodule CattlePurchase.Authorize do
  alias Accounts.User

  def list_pages(user, apps) do
    app = Enum.find(apps, &(&1.name == "Cattle Purchase"))
    role = "user"

    cond do
      role == "admin" ->
        [app]

      role == "user" ->
        [
          Map.put(app, :pages, [Enum.find(app.pages, &(&1.name == "Pages"))])
        ]

      true ->
        []
    end
  end

  def authorize(%User{} = user, page) do
    role = "user"

    cond do
      user.it_admin || role == "admin" -> true
      role == "user" && page == "page" -> true
      true -> false
    end
  end
end
