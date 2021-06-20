defmodule BnwDashboardWeb.BorrowingBase.WeightBreaks.WeightBreaksLive do
  use BnwDashboardWeb, :live_view

  alias BnwDashboardWeb.Router.Helpers, as: Routes
  alias BnwDashboardWeb.BorrowingBase.WeightBreaks.{
    ChangeWeightBreakComponent,
    EffectiveDates.EffectiveDatesLive
  }
  alias BorrowingBase.{
    Companies,
    WeightBreaks,
    Authorize,
    Users
  }

  defp fetch_companies(socket) do
    %{user_roles: user_roles, current_user: current_user} = socket.assigns
    companies =
      Companies.list_companies()
      |> Enum.filter(fn c -> current_user.it_admin || Enum.any?(user_roles, &(&1.app_admin || &1.company_id == c.id)) end)
    socket = cond do
      Enum.count(companies) == 1 ->
        company = Enum.at(companies, 0)
        assign(socket, company: company.id)
      true -> socket
    end
    assign(socket, companies: companies)
  end

  defp fetch_weight_breaks(socket) do
    %{company: company_id} = socket.assigns
    weight_breaks =
      cond do
        company_id -> WeightBreaks.list_weight_breaks(company_id)
        true -> []
      end
    assign(socket, weight_breaks: weight_breaks)
  end

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(session, socket)

    if connected?(socket) do
      WeightBreaks.subscribe()
      Companies.subscribe()
    end

    current_user = Map.get(socket.assigns, :current_user)
    roles = Users.list_roles(current_user.id)

    socket = assign(socket, user_roles: roles)

    cond do
      current_user && Authorize.authorize(current_user, "weight_breaks") ->
        {:ok, socket}
      true ->
        {:ok, redirect(socket, to: "/")}
    end
  end

  # handle params
  @impl true
  def handle_params(%{"company" => company_id} = params, uri, socket) do
    params = Map.delete(params, "company")
    socket =
      socket
      |> assign(company: String.to_integer(company_id))
      |> fetch_weight_breaks()
    handle_params(params, uri, socket)
  end

  @impl true
  def handle_params(%{"weight_break" => weight_break_id} = params, uri, socket) do
    %{weight_breaks: weight_breaks} = socket.assigns
    params = Map.delete(params, "weight_break")
    weight_break_id = String.to_integer(weight_break_id)
    weight_break = Enum.find(weight_breaks, &(&1.id == weight_break_id))
    lot_status_codes = WeightBreaks.list_lot_status_codes(weight_break)
    socket = assign(socket, weight_break: weight_break_id, lot_status_codes: lot_status_codes)
    handle_params(params, uri, socket)
  end

  @impl true
  def handle_params(%{"change" => "new"} = params, uri, socket) do
    %{company: company} = socket.assigns
    params = Map.delete(params, "change")
    changeset =
      WeightBreaks.new_weight_break()
      |> Map.put(:company_id, company)
      |> WeightBreaks.change_weight_break()

    socket = assign(socket, modal: :change, changeset: changeset)
    handle_params(params, uri, socket)
  end

  @impl true
  def handle_params(%{"change" => weight_break_id} = params, uri, socket) do
    params = Map.delete(params, "change")
    changeset =
      WeightBreaks.get_weight_break!(weight_break_id)
      |> WeightBreaks.change_weight_break()

    socket = assign(socket, modal: :change, changeset: changeset)
    handle_params(params, uri, socket)
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    socket =
      socket
      |> assign(app: "Borrowing Base",
                page_title: "BNW Dashboard · Borrowing Base · Weight Breaks",
                modal: Map.get(socket.assigns, :modal),
                changeset: Map.get(socket.assigns, :changeset),
                company: Map.get(socket.assigns, :company),
                weight_break: Map.get(socket.assigns, :weight_break))
      |> fetch_companies()
      |> fetch_weight_breaks()
    {:noreply, socket}
  end
  # end handle parsms

  # handle info
  @impl true
  def handle_info({:save, _params}, socket) do
    %{company: company} = socket.assigns
    socket = assign(socket, modal: nil, changeset: nil)
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{company: company}), replace: true)}
  end

  @impl true
  def handle_info({[:weight_break, :updated], weight_break}, socket) do
    %{changeset: changeset, modal: modal} = socket.assigns
    socket = cond do
      modal == :change && changeset.data.id == weight_break.id ->
        assign(socket, changeset: WeightBreaks.change_weight_break(weight_break))
      true -> socket
    end
    socket = fetch_weight_breaks(socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:weight_break, :deleted], weight_break}, socket) do
    %{changeset: changeset, modal: modal} = socket.assigns
    socket = cond do
      modal == :change && changeset.data.id == weight_break.id ->
        assign(socket, changeset: nil, modal: nil)
      true -> socket
    end
    socket = fetch_weight_breaks(socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:weight_break, _], weight_break}, socket) do
    %{company: company} = socket.assigns
    socket = cond do
      company == weight_break.company_id -> fetch_weight_breaks(socket)
      true -> socket
    end
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:lot_status_codes, :updated], %{weight_break_id: weight_break_id}}, socket) do
    weight_breaks = Map.get(socket.assigns, :weight_breaks, [%{id: nil}])
    weight_break = Enum.find(weight_breaks, &(&1.id == weight_break_id))
    current_weight_break = Map.get(socket.assigns, :weight_break)
    socket = cond do
      current_weight_break && weight_break ->
        weight_break = Enum.find(weight_breaks, &(&1.id == current_weight_break))
        lot_status_codes = WeightBreaks.list_lot_status_codes(weight_break)
        assign(socket, lot_status_codes: lot_status_codes)
      true -> socket
    end
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:company, action], company}, socket) do
    %{company: company_id} = socket.assigns
    socket = fetch_companies(socket)
    cond do
      action == :deleted && company.id == company_id ->
        socket = assign(socket, company: nil)
        {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__), replace: true)}
      true ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end
  # end handle info

  # handle event
  @impl true
  def handle_event("cancel", _, socket) do
    %{company: company} = socket.assigns
    socket = assign(socket, changeset: nil, modal: nil)
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{company: company}), replace: true)}
  end

  @impl true
  def handle_event("company", %{"company" => company}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{company: company}), replace: true)}
  end

  @impl true
  def handle_event("weight_break", %{"id" => weight_break_id}, socket) do
    %{company: company, weight_break: weight_break} = socket.assigns
    weight_break_id = String.to_integer(weight_break_id)
    cond do
      weight_break == weight_break_id ->
        socket = assign(socket, weight_break: nil)
        {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{company: company}), replace: true)}
      true ->
        {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{weight_break: weight_break_id, company: company}), replace: true)}
    end
  end

  @impl true
  def handle_event("new", _params, socket) do
    %{company: company} = socket.assigns
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{change: :new, company: company}), replace: true)}
  end

  @impl true
  def handle_event("edit", %{"id" => id}, socket) do
    %{company: company} = socket.assigns
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{change: id, company: company}), replace: true)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    WeightBreaks.get_weight_break!(id)
    |> WeightBreaks.delete_weight_break()
    {:noreply, socket}
  end

  @impl true
  def handle_event("lot_status_code", %{"id" => id}, socket) do
    %{weight_break: weight_break} = socket.assigns
    id = String.to_integer(id)
    WeightBreaks.add_lot_status_codes(weight_break, id)
    {:noreply, socket}
  end
  # end handle event
end
