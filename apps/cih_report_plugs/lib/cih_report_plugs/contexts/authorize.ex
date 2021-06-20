defmodule CihReportPlugs.Authorize do
  @moduledoc """
  The Authorization for the CIH plugs app.
  """

  import Ecto.Query

  alias Accounts.User
  alias CihReportPlugs.{
    Repo,
    UserRole
  }

  def list_pages(user, apps) do
    app = Enum.find(apps, &(&1.name == "CIH Report Plugs"))

    role = get_role(user.id)

    cond do
      role == "admin" ->
        [app]
      role == "user" ->
        [
          Map.put(app, :pages, [Enum.find(app.pages, &(&1.name == "Plugs"))])
        ]
      true ->
        []
    end
  end

  def authorize(%User{} = user, page) do
    role = get_role(user.id)
    cond do
      user.it_admin || role == "admin" -> true
      role == "user" && page == "plugs" -> true
      true -> false
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

  defp get_role(user_id) do
    role =
      UserRole
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
