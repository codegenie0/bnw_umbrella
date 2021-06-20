defmodule BnwDashboardWeb.ComponentApplications.ExternalApplications.ChangeExternalApplicationComponent do
  use BnwDashboardWeb, :live_component

  alias ComponentApplications.ExternalApplications
  alias BnwDashboardWeb.ComponentApplications.ExternalApplications.ExternalApplicationsLive

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("validate", %{"external_application" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset =
      changeset.data
      |> ExternalApplications.change_external_application(params)
      |> Map.put(:action, :update)

    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  def handle_event("save", %{"external_application" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    case ExternalApplications.create_or_update_external_application(changeset.data, params) do
      {:ok, _external_application} ->
        {:noreply, push_patch(socket, to: Routes.live_path(socket, ExternalApplicationsLive))}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
