defmodule BnwDashboardWeb.Plug.EnsureItAdmin do
  import Phoenix.Controller, only: [redirect: 2]
  import Plug.Conn, only: [halt: 1]

  def init(opts), do: Enum.into(opts, %{})

  def call(conn, opts \\ []) do
    check_it_admin(conn, opts)
  end

  defp check_it_admin(conn, _opts) do
    current_user = Guardian.Plug.current_resource(conn)
    cond do
      current_user.it_admin ->
        conn
      true ->
        halt_plug(conn)
    end
  end

  defp halt_plug(conn) do
    conn
    |> redirect(to: "/")
    |> halt()
  end
end
