defmodule CustomerAccess.Authorize do
  @moduledoc """
  The Authorization for the customer_access app.
  """
  import Ecto.Query

  alias CustomerAccess.{
    Repo,
    UserRole
  }

  @doc """
  Returns the list of pages for the customer_access app.

  ## Examples
    iex> list_pages(user, apps)
    [%{}]
  """
  def list_pages(user, apps) do
    app = Enum.find(apps, &(&1.name == "Customer Access"))

    role = get_role(user.id)

    cond do
      role == "admin" ->
        [app]
      user.customer || role == "user" ->
        [
          Map.put(app, :pages, [Enum.find(app.pages, &(&1.name == "Reports"))])
        ]
      true ->
        []
    end
  end

  def authorize(user, page) do
    role = get_role(user.id)
    cond do
      user.it_admin || role == "admin" -> true
      (user.customer || role == "user") && page == "reports" -> true
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
