defmodule BnwDashboardWeb.Reimbursement.Report.ChangeReportComponent do

  use BnwDashboardWeb, :live_component

  alias BnwDashboardWeb.Reimbursement.Report.ReportsLive
  alias Reimbursement.Reports

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"report" => report}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = Reports.validate(changeset.data, report)
    if changeset.valid? do
      case Reports.create_or_update_report(changeset.data, report) do
        {:ok, _report} ->
          {:noreply, push_patch(socket, to: Routes.live_path(socket, ReportsLive))}
        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
      {:noreply, socket}
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("validate", %{"report" => report}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = Reports.validate(changeset.data, report)
    {:noreply, assign(socket, changeset: changeset)}
  end
end
