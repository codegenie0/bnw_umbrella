defmodule BnwDashboardWeb.CustomerAccess.Reports.ReportTypesComponent do
  use BnwDashboardWeb, :live_component

  alias CustomerAccess.ReportTypes
  alias BnwDashboardWeb.CustomerAccess.Reports.ReportsLive

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("validate", %{"report_type" => params}, socket) do
    %{report_types: report_types} = socket.assigns
    id = Map.get(params, "id")
    changeset = Enum.find(report_types, &("#{&1.data.id}" == id))
    changeset = ReportTypes.change_report_type(changeset.data, params)
    |> Map.put(:action, :update)
    report_types = Enum.map(report_types, &(
      cond do
        (&1.data.id || "") == id -> changeset
        true -> &1
      end
    ))
    socket = assign(socket, report_types: report_types)
    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    %{report_types: report_types} = socket.assigns
    changeset = Enum.find(report_types, &("#{&1.data.id}" == id))
    ReportTypes.delete_report_type(changeset.data)
    {:noreply, push_patch(socket, to: Routes.live_path(socket, ReportsLive, %{report_types: true}), replace: true)}
  end

  def handle_event("save", %{"report_type" => params}, socket) do
    %{report_types: report_types} = socket.assigns
    id = Map.get(params, "id")
    changeset = Enum.find(report_types, &("#{&1.data.id}" == id))
    case ReportTypes.create_or_update_report_type(changeset.data, params) do
      {:ok, _report_type} ->
        {:noreply, push_patch(socket, to: Routes.live_path(socket, ReportsLive, %{report_types: true}), replace: true)}
      {:error, %Ecto.Changeset{} = changeset} ->
        report_types = Enum.map(report_types, &(
          cond do
            (&1.data.id || "") == id -> changeset
            true -> &1
          end
        ))
        socket = assign(socket, report_types: report_types)
        {:noreply, socket}
    end
  end
end
