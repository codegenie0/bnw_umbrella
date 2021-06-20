defmodule BnwDashboardWeb.BorrowingBase.Home.HomeLive do
  use BnwDashboardWeb, :live_view

  alias BorrowingBase.{
    Companies,
    EffectiveDates,
    WeightBreaks,
    Authorize,
    Users
  }
  alias BnwDashboardWeb.BorrowingBase.Home.{
    EffectiveDateLive
  }

  defp fetch_companies(socket) do
    %{company: company, current_user: current_user, user_roles: user_roles} = socket.assigns
    companies =
      Companies.list_companies()
      |> Enum.filter(fn c -> current_user.it_admin || Enum.any?(user_roles, &(&1.app_admin || &1.company_id == c.id)) end)
    company = get_individual(company, companies)
    assign(socket, companies: companies, company: company)
  end

  defp fetch_weight_breaks(socket) do
    %{company: company, weight_break: weight_break} = socket.assigns
    weight_breaks = cond do
      company -> WeightBreaks.list_weight_breaks(String.to_integer(company))
      true -> %{}
    end
    weight_break = get_individual(weight_break, weight_breaks)
    assign(socket, weight_breaks: weight_breaks, weight_break: weight_break)
  end

  defp fetch_effective_dates(socket) do
    %{
      weight_break: weight_break,
      weight_breaks: weight_breaks,
      effective_date: effective_date,
      effective_date_page: page,
      effective_date_search: search,
      effective_date_per_page: per_page
    } = socket.assigns
    {effective_dates, total_pages} = cond do
      weight_break ->
        wb = Enum.find(weight_breaks, &("#{&1.id}" == weight_break))
        {
          EffectiveDates.list_effective_dates(wb, page, per_page, search),
          EffectiveDates.total_pages(wb, per_page, search)
        }
      true -> {%{}, nil}
    end

    effective_date = get_individual(effective_date, effective_dates)
    assign(socket, effective_dates: effective_dates, effective_date: effective_date, effective_date_total_pages: total_pages)
  end

  defp get_individual(i, list) do
    cond do
      Enum.empty?(list) -> nil
      i -> i
      true ->
        Enum.at(list, 0)
        |> Map.get(:id)
        |> Integer.to_string()
    end
  end

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(session, socket)
    |> assign(socket, app: "Borrowing Base",
                      page_title: "BNW Dashboard · Borrowing Base · Home")

    if connected?(socket) do
      Companies.subscribe()
      WeightBreaks.subscribe()
      EffectiveDates.subscribe()
    end

    current_user = Map.get(socket.assigns, :current_user)
    user_roles = Users.list_roles(current_user.id)
    socket = assign(socket, user_roles: user_roles)

    cond do
      current_user && Authorize.authorize(current_user, "home") ->
        {:ok, socket}
      true ->
        {:ok, redirect(socket, to: "/")}
    end
  end

  # handle params
  @impl true
  def handle_params(params, _uri, socket) do
    company = Map.get(socket.assigns, :company)
    weight_break = Map.get(socket.assigns, :weight_break)
    effective_date = Map.get(socket.assigns, :effective_date)
    effective_date_search = Map.get(socket.assigns, :effective_date_search)
    socket =
      assign(socket, app: "Borrowing Base",
                     page_title: "BNW Dashboard · Borrowing Base · Home",
                     company: Map.get(params, "company", company),
                     weight_break: Map.get(params, "weight_break", weight_break),
                     effective_date: Map.get(params, "effective_date", effective_date),
                     effective_date_page: 1,
                     effective_date_search: Map.get(params, "effective_date_search", effective_date_search),
                     effective_date_per_page: 30,
                     effective_date_update_action: "replace")
      |> fetch_companies()
      |> fetch_weight_breaks()
      |> fetch_effective_dates()
    {:noreply, socket}
  end
  # handle params end

  # handle info
  @impl true
  def handle_info({[:effective_date, :created], _result}, socket) do
    socket = fetch_effective_dates(socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:effective_date, :updated], _result}, socket) do
    socket = fetch_effective_dates(socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:effective_date, :deleted], result}, socket) do
    %{effective_date: effective_date, effective_dates: effective_dates} = socket.assigns
    socket =
      cond do
        effective_date == "#{result.id}" && result.id == Map.get(Enum.at(effective_dates, 0), :id) ->
          assign(socket, effective_date: "#{Map.get(Enum.at(effective_dates, 1), :id)}")
        effective_date == "#{result.id}" ->
          assign(socket, effective_date: "#{Map.get(Enum.at(effective_dates, 0), :id)}")
        true -> socket
      end
      |> fetch_effective_dates()
    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end
  # handle info end

  # handle event
  def handle_event("company", %{"company" => company}, socket) do
    socket = assign(socket, weight_break: nil, effective_date: nil)
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{company: company}), replace: true)}
  end

  @impl true
  def handle_event("weight_break", %{"weight-break" => weight_break}, socket) do
    %{company: company} = socket.assigns
    socket = assign(socket, effective_date: nil)
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, %{weight_break: weight_break, company: company}), replace: true)}
  end

  @impl true
  def handle_event("load_more", _, socket) do
    %{
      effective_date_page: page,
      effective_date_per_page: per_page,
      effective_date_search: search,
      effective_date_total_pages: total_pages,
      weight_break: weight_break,
      weight_breaks: weight_breaks
    } = socket.assigns
    page = page + 1
    cond do
      page > total_pages ->
        {:noreply, socket}
      true ->
        wb = Enum.find(weight_breaks, &("#{&1.id}" == weight_break))
        effective_dates = EffectiveDates.list_effective_dates(wb, page, per_page, search)
        socket = assign(socket, effective_date_update_action: "append",
                                effective_date_page: page,
                                effective_dates: effective_dates)
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("search_effective_date", %{"search" => %{"search" => search}}, socket) do
    %{
      effective_date_per_page: per_page,
      weight_break: weight_break,
      weight_breaks: weight_breaks
    } = socket.assigns
    page = 1
    wb = Enum.find(weight_breaks, &("#{&1.id}" == weight_break))
    effective_dates = EffectiveDates.list_effective_dates(wb, page, per_page, search)
    total_pages = EffectiveDates.total_pages(wb, per_page, search)
    socket = assign(socket, effective_date_update_action: "replace",
                            effective_dates: effective_dates,
                            effective_date_total_pages: total_pages)
    {:noreply, socket}
  end

  @impl true
  def handle_event("select_date", %{"id" => id}, socket) do
    socket = assign(socket, effective_date: id)
    {:noreply, socket}
  end

  @impl true
  def handle_event("change_locked", %{"id" => id}, socket) do
    %{effective_dates: effective_dates} = socket.assigns
    effective_date = Enum.find(effective_dates, &("#{&1.id}" == id))
    EffectiveDates.create_or_update_effective_date(effective_date, %{"locked" => !effective_date.locked})
    {:noreply, socket}
  end
  # handle event end
end
