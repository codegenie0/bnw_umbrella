defmodule BnwDashboardWeb.ComponentApplications.ExternalApplications.ExternalApplicationsLive do
  use BnwDashboardWeb, :live_view

  alias BnwDashboardWeb.ComponentApplications.ExternalApplications.ChangeExternalApplicationComponent
  alias BnwDashboardWeb.Router.Helpers, as: Routes
  alias ComponentApplications.ExternalApplications

  defp fetch_external_applications(socket) do
    external_applications = ExternalApplications.list_external_applications()
    assign(socket, external_applications: external_applications)
  end

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(session, socket)
    |> assign(socket, page_title: "BNW Dashboard · External Applications", modal: nil, changeset: nil, app: "Applications")
    if connected?(socket), do: ExternalApplications.subscribe()
    cond do
      socket.assigns.current_user.it_admin ->
        {:ok, socket}
      true ->
        {:ok, redirect(socket, to: "/")}
    end
  end

  @impl true
  def handle_params(%{"change" => change}, _uri, socket) do
    changeset = cond do
      change == "new" ->
        ExternalApplications.new_external_application()
        |> ExternalApplications.change_external_application()
      true ->
        ExternalApplications.get_external_application!(change)
        |> ExternalApplications.change_external_application()
    end
    socket = fetch_external_applications(socket)
    |> assign(modal: :change_external_application, changeset: changeset)
    {:noreply, socket}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    socket = assign(socket, modal: nil, changeset: nil, page_title: "BNW Dashboard · External Applications", app: "Applications")
    |> fetch_external_applications()
    {:noreply, socket}
  end

  # handle info
  @impl true
  def handle_info({[:external_application, :updated], external_application}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = cond do
      changeset && changeset.data.id == external_application.id ->
        ExternalApplications.change_external_application(external_application)
      true -> changeset
    end
    socket = fetch_external_applications(socket)
    |> assign(changeset: changeset)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:external_application, :created], _external_application}, socket) do
    {:noreply, fetch_external_applications(socket)}
  end

  @impl true
  def handle_info({[:external_application, :deleted], _external_application}, socket) do
    {:noreply, fetch_external_applications(socket)}
  end
  # handle info end

  # handle event
  @impl true
  def handle_event("new", _params, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{change: :new}), replace: true)}
  end

  @impl true
  def handle_event("edit", %{"id" => id}, socket) do
    id = String.to_integer(id)
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{change: id}), replace: true)}
  end

  @impl true
  def handle_event("cancel", _params, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__), replace: true)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    external_application = ExternalApplications.get_external_application!(id)
    case ExternalApplications.delete_external_application(external_application) do
      {:ok, _external_application} ->
        {:noreply, socket}
      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Could not delete!")}
    end
  end
  # handle event end
end
