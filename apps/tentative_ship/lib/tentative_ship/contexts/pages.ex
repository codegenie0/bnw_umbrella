defmodule TentativeShip.Pages do
  @moduledoc """
  The Pages for the tentative_ship app.
  """

  @doc """
  Returns the list of pages for the tentative_ship app.

  ## Examples
    iex> list_pages()
    [%{}]
  """
  def list_pages() do
    [
      %{name: "Home", url: "/tentative_ship/home"},
      %{name: "Default Roles", url: "/tentative_ship/default_roles"},
      %{name: "Customers", url: "/tentative_ship/customers"},
      %{name: "Permissions", url: "/tentative_ship/permissions"},
      %{name: "Users", url: "/tentative_ship/users"},
      %{name: "Yards", url: "/tentative_ship/yards"}
    ]
  end
end
