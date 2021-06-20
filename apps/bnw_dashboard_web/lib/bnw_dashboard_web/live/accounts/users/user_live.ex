defmodule BnwDashboardWeb.Accounts.Users.UserLive do
  use BnwDashboardWeb, :live_view

  alias Accounts.{
    Authenticate,
    Users
  }
  alias BnwDashboardWeb.Accounts.Users.{
    ChangeUserComponent,
    ChangeUserPasswordComponent
  }

  @impl true
  def mount(_params, %{"user" => user}, socket) do
    socket = assign(socket, user: user, modal: nil, changeset: nil)
    if connected?(socket), do: Users.subscribe()
    {:ok, socket}
  end

  # handle_info
  @impl true
  def handle_info({[:user, :updated], updated_user}, socket) do
    %{user: user, modal: modal} = socket.assigns
    socket = cond do
      user.id == updated_user.id && modal == :change_user ->
        changeset = Users.change_user(updated_user)
        assign(socket, user: updated_user, changeset: changeset)
      user.id == updated_user.id -> assign(socket, user: updated_user)
      true -> socket
    end
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:user, :deleted], updated_user}, socket) do
    %{user: user} = socket.assigns
    socket = cond do
      user.id == updated_user.id -> assign(socket, user: nil, modal: nil, changeset: nil)
      true -> socket
    end
    {:noreply, socket}
  end

  @impl true
  def handle_info({:save, _params}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end
  # end handle_info

  # handle_event
  @impl true
  def handle_event("change_active", _, socket) do
    %{user: user} = socket.assigns
    Users.create_or_update_user(user, %{"active" => !user.active})
    {:noreply, socket}
  end

  @impl true
  def handle_event("change", %{"switch" => switch}, socket) do
    %{user: user} = socket.assigns
    case switch do
      "active" ->
        Users.create_or_update_user(user, %{"active" => !user.active})
      "it_admin" ->
        Users.create_or_update_user(user, %{"it_admin" => !user.it_admin})
      "allow_request_app_access" ->
        Users.create_or_update_user(user, %{"allow_request_app_access" => !user.allow_request_app_access})
      "allow_password_reset" ->
        Users.create_or_update_user(user, %{"allow_password_reset" => !user.allow_password_reset})
      _ -> nil
    end
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit", _, socket) do
    %{user: user} = socket.assigns
    changeset = Users.change_user(user)
    socket = assign(socket, changeset: changeset, modal: :change_user)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", _, socket) do
    %{user: user} = socket.assigns
    Users.delete_user(user)
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, changeset: nil, modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_event("change_password", _, socket) do
    %{user: user} = socket.assigns
    changeset = Authenticate.change_user(user)
    socket = assign(socket, modal: :change_user_password, changeset: changeset)
    {:noreply, socket}
  end
  # end handle_event
end
