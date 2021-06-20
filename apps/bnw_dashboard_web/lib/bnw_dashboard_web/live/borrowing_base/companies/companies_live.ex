defmodule BnwDashboardWeb.BorrowingBase.Companies.CompaniesLive do
  use BnwDashboardWeb, :live_view

  alias BnwDashboardWeb.Router.Helpers, as: Routes
  alias BnwDashboardWeb.BorrowingBase.Companies.{
    ChangeCompanyComponent,
    Yards.YardsLive,
    Roles.RolesLive,
    Users.UsersLive,
    SexCodes.SexCodesLive,
    LotStatusCodes.LotStatusCodesLive
  }
  alias BorrowingBase.{
    Authorize,
    Companies,
    Users
  }

  defp fetch_companies(socket) do
    %{user_roles: user_roles, current_user: current_user} = socket.assigns
    companies =
      Companies.list_companies()
      |> Enum.filter(fn c -> current_user.it_admin || Enum.any?(user_roles, &(&1.app_admin || c.id == &1.company_id)) end)
    assign(socket, companies: companies)
  end

  @impl true
  def mount(_params, session, socket) do
    socket =
      assign_defaults(session, socket)
      |> assign(socket, app: "Borrowing Base",
                        page_title: "BNW Dashboard · Borrowing Base · Companies",
                        modal: nil,
                        changeset: nil)

    current_user = Map.get(socket.assigns, :current_user)
    user_roles = Users.list_roles(current_user.id)
    socket = assign(socket, user_roles: user_roles)

    if connected?(socket), do: Companies.subscribe()
    cond do
      current_user && Authorize.authorize(current_user, "companies") ->
        {:ok, socket}
      true ->
        {:ok, redirect(socket, to: "/")}
    end
  end

  # handle params
  @impl true
  def handle_params(%{"change" => "new"} = params, uri, socket) do
    params = Map.delete(params, "change")
    changeset =
      Companies.new_company()
      |> Companies.change_company()

    socket = assign(socket, modal: :change, changeset: changeset)
    handle_params(params, uri, socket)
  end

  @impl true
  def handle_params(%{"change" => company_id} = params, uri, socket) do
    params = Map.delete(params, "change")
    changeset =
      Companies.get_company!(company_id)
      |> Companies.change_company()

    socket = assign(socket, modal: :change, changeset: changeset)
    handle_params(params, uri, socket)
  end

  @impl true
  def handle_params(%{"yards" => _, "company" => company} = params, uri, socket) do
    params = Map.delete(params, "yards")
    socket = assign(socket, modal: :yards, company: String.to_integer(company))
    handle_params(params, uri, socket)
  end

  @impl true
  def handle_params(%{"roles" => _, "company" => company} = params, uri, socket) do
    params = Map.delete(params, "roles")
    socket = assign(socket, modal: :roles, company: String.to_integer(company))
    handle_params(params, uri, socket)
  end

  @impl true
  def handle_params(%{"users" => _, "company" => company} = params, uri, socket) do
    params = Map.delete(params, "users")
    socket = assign(socket, modal: :users, company: String.to_integer(company))
    handle_params(params, uri, socket)
  end

  @impl true
  def handle_params(%{"sex_codes" => _, "company" => company} = params, uri, socket) do
    params = Map.delete(params, "sex_codes")
    socket = assign(socket, modal: :sex_codes, company: String.to_integer(company))
    handle_params(params, uri, socket)
  end

  @impl true
  def handle_params(%{"lot_status_codes" => _, "company" => company} = params, uri, socket) do
    params = Map.delete(params, "lot_status_codes")
    socket = assign(socket, modal: :lot_status_codes, company: String.to_integer(company))
    handle_params(params, uri, socket)
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    socket =
      fetch_companies(socket)
      |> assign(app: "Borrowing Base",
                page_title: "BNW Dashboard · Borrowing Base · Companies",
                modal: Map.get(socket.assigns, :modal),
                changeset: Map.get(socket.assigns, :changeset))
    {:noreply, socket}
  end
  # end handle parsms

  # handle info
  def handle_info({:save, _params}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
    {:noreply, socket}
  end

  def handle_info({[:company, :updated], company}, socket) do
    %{changeset: changeset, modal: modal} = socket.assigns
    socket = cond do
      modal == :change && changeset.data.id == company.id ->
        assign(socket, changeset: Companies.change_company(company))
      true -> socket
    end
    socket = fetch_companies(socket)
    {:noreply, socket}
  end

  def handle_info({[:company, :deleted], company}, socket) do
    %{changeset: changeset, modal: modal} = socket.assigns
    socket = cond do
      modal == :change && changeset.data.id == company.id ->
        assign(socket, changeset: nil, modal: nil)
      true -> socket
    end
    socket = fetch_companies(socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:company, _], _company}, socket) do
    socket = fetch_companies(socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end
  # end handle info

  # handle event
  @impl true
  def handle_event("new", _params, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{change: :new}), replace: true)}
  end

  @impl true
  def handle_event("edit", %{"id" => id}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{change: id}), replace: true)}
  end

  @impl true
  def handle_event("yards", %{"company" => company_id}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{yards: true, company: company_id}), replace: true)}
  end

  @impl true
  def handle_event("roles", %{"company" => company_id}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{roles: true, company: company_id}), replace: true)}
  end

  @impl true
  def handle_event("users", %{"company" => company_id}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{users: true, company: company_id}), replace: true)}
  end

  @impl true
  def handle_event("sex_codes", %{"company" => company_id}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{sex_codes: true, company: company_id}), replace: true)}
  end

  @impl true
  def handle_event("lot_status_codes", %{"company" => company_id}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{lot_status_codes: true, company: company_id}), replace: true)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    Companies.get_company!(id)
    |> Companies.delete_company()
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, changeset: nil, modal: nil)
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__), replace: true)}
  end
  # end handle event
end
