defmodule CattlePurchase.Authorize do
  import Ecto.Query

  alias CattlePurchase.{
    Repo,
    UserRole
  }

  def list_pages(user, apps) do
    app = Enum.find(apps, &(&1.name == "Cattle Purchase"))
    role = get_role(user.id)


    cond do
      role == "admin" ->
        [app]

      role == "user" ->
        [
          Map.put(app, :pages, [Enum.find(app.pages, &(&1.name == "Page"))])
        ]

      true ->
        []
    end
  end

  def authorize(user, page) do
    role = get_role(user.id)
    cond do
      user.it_admin || role == "admin" -> true
      (user.customer || role == "user") && page == "Page" -> true
      true -> false
    end
  end

  defp get_role(user_id) do
    role = UserRole
    |> where([ur], ur.user_id == ^user_id)
    |> select([ur], [ur.role])
    |> order_by([ur], desc: fragment("field(?, 'user', 'admin')", ur.role))
    |> limit(1)
    |> Repo.one()

    cond do
      role -> Enum.at(role, 0)
      true -> nil
    end
  end
end
