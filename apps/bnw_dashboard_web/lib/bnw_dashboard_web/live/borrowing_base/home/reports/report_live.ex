defmodule BnwDashboardWeb.BorrowingBase.Home.Reports.ReportLive do
  use BnwDashboardWeb, :live_view

  alias BorrowingBase.Reports

  defp build_url(socket) do
    %{
      current_user: current_user,
      changeset: changeset,
      effective_date: effective_date,
      weight_break: weight_break,
      yard: yard
    } = socket.assigns

    %{url: url} = changeset.data
    cond do
      url ->
        url = cond do
          String.contains?(url, "decorate=no") -> url
          true -> url <> "&decorate=no"
        end

        url = cond do
          String.contains?(url, "j_password") -> url
          true -> url <> "&j_password=rxFlMe4nR3mXCJA"
        end

        url = cond do
          String.contains?(url, "j_username") -> url
          true -> url <> "&j_username=borrowing_base"
        end

        url = url <> "&effective_date_id=#{effective_date.id}"
        url = url <> "&weight_break_id=#{weight_break.id}"
        url = url <> "&yard_id=#{yard.id}"
        url = url <> "&company_id=#{weight_break.company_id}"
        url = url <> "&current_user_id=#{current_user.id}"

        assign(socket, url: url)
      true -> socket
    end
  end

  @impl true
  def mount(_params, session, socket) do
    %{
      "changeset" => changeset,
      "current_user" => current_user,
      "effective_date" => effective_date,
      "weight_break" => weight_break,
      "yard" => yard
    } = session

    socket = assign(socket,
      changeset: changeset,
      current_user: current_user,
      effective_date: effective_date,
      weight_break: weight_break,
      yard: yard)
    |> build_url()
    if connected?(socket), do: Reports.subscribe()
    {:ok, socket}
  end

  # handle info
  @impl true
  def handle_info({[:report, :updated], report}, socket) do
    %{changeset: changeset} = socket.assigns
    socket = cond do
      changeset.data.id == report.id ->
        changeset = Reports.change_report(report)
        socket
        |> assign(changeset: changeset)
        |> build_url()
      true -> socket
    end
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:report, :created], report}, socket) do
    %{changeset: changeset} = socket.assigns
    socket = cond do
      is_nil(changeset.data.id) ->
        changeset = Reports.change_report(report)
        socket
        |> assign(changeset: changeset)
        |> build_url()
      true -> socket
    end
    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end
  # end handle info

  # handle event
  @impl true
  def handle_event("delete", _params, socket) do
    %{changeset: changeset} = socket.assigns
    Reports.delete_report(changeset.data)
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"report" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = Reports.change_report(changeset.data, params)
    |> Map.put(:action, :update)
    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"report" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    case Reports.create_or_update_report(changeset.data, params) do
      {:ok, _report} ->
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, changeset: changeset)
        {:noreply, socket}
    end
  end
  # end handle event
end
