defmodule TentativeShip.Authorize do
  @moduledoc """
  The Authorization for the borrowing_base app.
  """

  alias TentativeShip.Users

  @doc """
  Returns the list of pages for the borrowing_base app.

  ## Examples
    iex> list_pages(user, apps)
    [%{}]
  """
  def list_pages(user, apps) do
    roles = Users.list_roles(user.id)

    app = Enum.find(apps, &(&1.name == "Tentative Shipments"))

    cond do
      Enum.any?(roles, &(&1.app_admin)) ->
        [Map.put(app, :pages, Enum.reject(app.pages, &(&1.name == "Permissions" || &1.name == "Users")))]
      !Enum.empty?(roles) ->
        [Map.put(app, :pages, Enum.filter(app.pages, &(&1.name == "Home")))]
      true ->
        []
    end
  end

  def authorize(user, page) do
    # roles = Users.list_roles(user.id)
    # cond do
    #   user.it_admin || Enum.any?(roles, &(&1.app_admin || &1.company_admin)) -> true
    #   !Enum.empty?(roles) && page == "home" -> true
    #   true -> false
    # end
    true
  end
end
