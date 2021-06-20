defmodule BnwDashboardWeb.CustomerAccess.Reports.ChangeReportComponent do
  use BnwDashboardWeb, :live_component

  alias CustomerAccess.Reports
  alias BnwDashboardWeb.CustomerAccess.Reports.ReportsLive

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("validate", %{"report" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset =
      changeset.data
      |> Reports.change_report(params)
      |> Map.put(:action, :update)

    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  def handle_event("save", %{"report" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    case Reports.create_or_update_report(changeset.data, params) do
      {:ok, _report} ->
        {:noreply, push_patch(socket, to: Routes.live_path(socket, ReportsLive, %{cancel: true}), replace: true)}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
