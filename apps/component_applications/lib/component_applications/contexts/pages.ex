defmodule ComponentApplications.Pages do
  @moduledoc """
  The Pages for the component_applications app.
  """

  @doc """
  Returns the list of pages for the component_applications app.

  ## Examples
    iex> list_pages()
    [%{}]
  """
  def list_pages() do
    [
      %{name: "External Applications", url: "/applications/external"}
    ]
  end
end
