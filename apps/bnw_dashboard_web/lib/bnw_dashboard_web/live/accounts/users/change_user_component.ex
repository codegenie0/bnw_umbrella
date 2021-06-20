defmodule BnwDashboardWeb.Accounts.Users.ChangeUserComponent do
  use BnwDashboardWeb, :live_component

  alias Accounts.Users

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("validate", %{"user" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset =
      changeset.data
      |> Users.change_user(params)
      |> Map.put(:action, :update)

    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  def handle_event("save", %{"user" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    case Users.create_or_update_user(changeset.data, params) do
      {:ok, _user} ->
        send self(), {:save, nil}
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
