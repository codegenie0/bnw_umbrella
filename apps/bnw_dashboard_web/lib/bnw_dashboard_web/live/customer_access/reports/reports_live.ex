defmodule BnwDashboardWeb.CustomerAccess.Reports.ReportsLive do
  use BnwDashboardWeb, :live_view

  alias BnwDashboardWeb.CustomerAccess.Reports.{
    ChangeReportComponent,
    ReportTypesComponent,
    SelectCustomerComponent
  }
  alias BnwDashboardWeb.Router.Helpers, as: Routes
  alias CustomerAccess.{
    Authorize,
    Customers,
    Reports,
    ReportTypes,
  }

  defp fetch_reports(socket) do
    reports = Reports.list_reports()
    |> Enum.group_by(&(if &1.report_type, do: &1.report_type.name, else: &1.report_type))
    assign(socket, reports: reports)
  end

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(session, socket)
    |> assign(socket, page_title: "BNW Dashboard · Customer Reports", modal: nil, changeset: nil, app: "Customer Access")

    current_user = Map.get(socket.assigns, :current_user)

    if connected?(socket), do: Reports.subscribe()
    cond do
      current_user && Authorize.authorize(current_user, "reports") ->
        socket = cond do
          current_user.customer ->
            customer = Customers.get_customer_by(:username, current_user.username)
            assign(socket, customer: customer)
          true -> socket
        end
        {:ok, socket}
      true ->
        {:ok, redirect(socket, to: "/")}
    end
  end

  @impl true
  def handle_params(%{"change" => change} = params, uri, %{assigns: %{current_user: %{it_admin: true}}} = socket) do
    params = Map.delete(params, "change")
    changeset = cond do
      change == "new" ->
        Reports.new_report()
        |> Reports.change_report()
      true ->
        Reports.get_report!(change)
        |> Reports.change_report()
    end

    report_types = ReportTypes.list_report_types()
    |> Enum.map(&({&1.name, &1.id}))
    |> List.insert_at(0, nil)

    socket = fetch_reports(socket)
    |> assign(modal: :change_report, changeset: changeset, report_types: report_types)

    if connected?(socket), do: ReportTypes.subscribe()

    handle_params(params, uri, socket)
  end

  @impl true
  def handle_params(%{"report_types" => _report_types} = params, uri, %{assigns: %{current_user: %{it_admin: true}}} = socket) do
    params = Map.delete(params, "report_types")
    report_types = (ReportTypes.list_report_types() ++ [ReportTypes.new_report_type()])
    |> Enum.map(&ReportTypes.change_report_type(&1))
    socket = assign(socket, modal: :report_types, report_types: report_types)
    |> fetch_reports()
    if connected?(socket), do: ReportTypes.subscribe()
    handle_params(params, uri, socket)
  end

  @impl true
  def handle_params(%{"select_customer" => _select_customer, "search" => search} = params, uri, %{assigns: %{current_user: %{customer: false}}} = socket) do
    params =
      params
      |> Map.delete("select_customer")
      |> Map.delete("search")

    page = 1
    per_page = 20
    socket = assign(socket, modal: :select_customer,
                            customers: Customers.list_customers(page, per_page, search),
                            page: page,
                            search: search,
                            per_page: per_page,
                            total_pages: Customers.total_pages(per_page, search),
                            update_action: "replace")
    |> fetch_reports()
    if connected?(socket), do: Customers.subscribe()
    handle_params(params, uri, socket)
  end

  @impl true
  def handle_params(%{"customer" => customer} = params, uri, %{assigns: %{current_user: %{customer: false}}} = socket) do
    params = Map.delete(params, "customer")
    customer = Customers.get_customer_by(:username, customer)
    socket = assign(socket, customer: customer, modal: nil)
    handle_params(params, uri, socket)
  end

  @impl true
  def handle_params(%{"cancel" => _cancel} = params, uri, socket) do
    params = Map.delete(params, "cancel")
    socket = assign(socket, modal: nil, changeset: nil)
    handle_params(params, uri, socket)
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    socket = assign(socket, page_title: "BNW Dashboard · Customer Reports",
                            app: "Customer Access",
                            modal: Map.get(socket.assigns, :modal),
                            changeset: Map.get(socket.assigns, :changeset),
                            customer: Map.get(socket.assigns, :customer))
    |> fetch_reports()

    {:noreply, socket}
  end

  # handle info
  @impl true
  def handle_info({[:report, :updated], report}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = cond do
      changeset && changeset.data.id == report.id ->
        Reports.change_report(report)
      true -> changeset
    end
    socket = fetch_reports(socket)
    |> assign(changeset: changeset)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:report, :created], _report}, socket) do
    {:noreply, fetch_reports(socket)}
  end

  @impl true
  def handle_info({[:report, :deleted], _report}, socket) do
    {:noreply, fetch_reports(socket)}
  end

  @impl true
  def handle_info({[:report_type, :updated], _report_type}, socket) do
    cond do
      Map.get(socket.assigns, :modal) == :report_types ->
        {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{report_types: true}), replace: true)}
      true ->
        {:noreply, socket}
    end
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
  def handle_event("report_types", _params, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{report_types: true}), replace: true)}
  end

  @impl true
  def handle_event("cancel", _params, socket) do
    customer = Map.get(socket.assigns, :customer)
    socket = assign(socket, modal: nil, changeset: nil, search: nil)

    cond do
      customer ->
        {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{customer: customer.username}), replace: true)}
      true ->
        {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__), replace: true)}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    report = Reports.get_report!(id)
    case Reports.delete_report(report) do
      {:ok, _report} ->
        {:noreply, socket}
      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Could not delete!")}
    end
  end

  @impl true
  def handle_event("select_customer", _params, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{select_customer: true, search: ""}), replace: true)}
  end

  @impl true
  def handle_event("load_more", _, socket) do
    %{page: page, per_page: per_page, search: search, total_pages: total_pages} = socket.assigns
    page = page + 1
    cond do
      page > total_pages ->
        {:noreply, socket}
      true ->
        customers = Customers.list_customers(page, per_page, search)
        socket = assign(socket, update_action: "append", page: page, customers: customers)
        {:noreply, socket}
    end
  end
  # handle event end
end
