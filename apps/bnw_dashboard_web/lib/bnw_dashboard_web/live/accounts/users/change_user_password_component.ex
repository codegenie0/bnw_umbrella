defmodule BnwDashboardWeb.Accounts.Users.ChangeUserPasswordComponent do
  use BnwDashboardWeb, :live_component
  use Phoenix.HTML

  alias Accounts.Authenticate

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("validate", %{"user" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = changeset.data
    |> Authenticate.change_user(params)
    |> Map.put(:action, :update)

    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  def handle_event("save", %{"user" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    case Authenticate.update_user(changeset.data, params) do
      {:ok, _user} ->
        send self(), {:save, nil}
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("random_password", _params, socket) do
    %{changeset: changeset} = socket.assigns
    password = :crypto.strong_rand_bytes(8)
    |> Base.encode64
    |> binary_part(0, 8)

    changeset = changeset.data
    |> Authenticate.change_user(%{"password" => password, "password_confirmation" => password})
    |> Map.put(:action, :update)

    socket = assign(socket, changeset: changeset, random_password: password)
    {:noreply, socket}
  end
end
