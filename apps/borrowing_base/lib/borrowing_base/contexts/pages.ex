defmodule BorrowingBase.Pages do
  @moduledoc """
  The Pages for the borrowing_base app.
  """

  @doc """
  Returns the list of pages for the borrowing_base app.

  ## Examples
    iex> list_pages()
    [%{}]
  """
  def list_pages() do
    [
      %{name: "Home", url: "/borrowing_base/home"},
      %{name: "Companies", url: "/borrowing_base/companies"},
      %{name: "Weight Breaks", url: "/borrowing_base/weight_breaks"}
    ]
  end
end
