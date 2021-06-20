defmodule Accounts.Pages do
  @moduledoc """
  The Pages for the accounts app.
  """

  @doc """
  Returns the list of pages for the accounts app.

  ## Examples
    iex> list_pages()
    [%{}]
  """
  def list_pages() do
    [
      %{name: "Users", url: "/accounts/users"}
    ]
  end
end
