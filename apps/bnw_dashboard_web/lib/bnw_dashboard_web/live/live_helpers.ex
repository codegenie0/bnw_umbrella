defmodule BnwDashboardWeb.LiveHelpers do
  use Phoenix.LiveView

  alias Accounts.{Users, Authenticate}

  def render(assigns), do: ~L""

  def assign_defaults(%{"guardian_default_token" => token}, socket) do
    {:ok, %{"sub" => user_id}} = Authenticate.decode_and_verify(token)

    socket = assign_new(socket, :current_user, fn -> Users.get_user(user_id) end)

    if socket.assigns.current_user.active do
      if connected?(socket) do
        Users.unsubscribe(user_id)
        Users.subscribe(user_id)
      end
      socket
    else
      redirect(socket, to: "/auth/request")
    end
  end
end
