defmodule BnwDashboardWeb.PlugsApp.Helpers.ChangeReportComponent do
  use BnwDashboardWeb, :live_component

  alias PlugsApp.Reports

  def mount(socket) do
    {:ok, assign(socket, show_report: false)}
  end

  def handle_event("show", %{"id" => id}, socket) do
    report = String.to_integer(id)
    |> Reports.get_report("")
    {:noreply, assign(socket, report: report, show_report: true)}
  end

  def handle_event("new", %{"new" => report}, socket) do
    changeset = Reports.new_report()
    |> Reports.change_report()
    changeset = Reports.validate(changeset.data, report)
    if changeset.valid? do
      case Reports.create_or_update_report(changeset.data, report) do
        {:ok, _report} ->
          {:noreply, socket}
        {:error, %Ecto.Changeset{} = changest} ->
          {:noreply, assign(socket, changeset: changest)}
      end
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    Reports.get_report(id)
    |> Reports.delete_report()
    {:noreply, socket}
  end
end
