defmodule CustomerAccess.Pages do
  @moduledoc """
  The Pages for the customer_access app.
  """

  @doc """
  Returns the list of pages for the customer_access app.

  ## Examples
    iex> list_pages()
    [%{}]
  """
  def list_pages() do
    [
      %{name: "Customers", url: "/customer_access/customers"},
      %{name: "Reports", url: "/customer_access/reports"},
      %{name: "Users", url: "/customer_access/users"}
    ]
  end
end
