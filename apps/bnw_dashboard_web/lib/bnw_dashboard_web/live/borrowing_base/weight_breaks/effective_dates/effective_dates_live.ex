defmodule BnwDashboardWeb.BorrowingBase.WeightBreaks.EffectiveDates.EffectiveDatesLive do
  use BnwDashboardWeb, :live_view

  alias BorrowingBase.{
    EffectiveDates,
    WeightBreaks
  }
  alias BnwDashboardWeb.BorrowingBase.WeightBreaks.EffectiveDates.{
    ChangeEffectiveDateComponent,
    CopyEffectiveDateComponent,
    EffectiveDateLive
  }


  defp fetch_effective_dates(socket) do
    %{
      page: page,
      per_page: per_page,
      search: search,
      weight_break: weight_break
    } = socket.assigns

    effective_dates = EffectiveDates.list_effective_dates(weight_break, page, per_page, search)
    total_pages = EffectiveDates.total_pages(weight_break, per_page, search)
    assign(socket, effective_dates: effective_dates, total_pages: total_pages)
  end

  @impl true
  def mount(_params, %{"weight_break" => weight_break}, socket) do
    page = 1
    per_page = 20
    search = ""
    socket =
      assign(socket, weight_break: weight_break,
                     page: page,
                     per_page: per_page,
                     search: search,
                     total_pages: EffectiveDates.total_pages(weight_break, per_page, search),
                     update_action: "replace",
                     modal: nil)
      |> fetch_effective_dates()
    %{effective_dates: effective_dates} = socket.assigns
    socket = assign(socket, effective_date: Enum.at(effective_dates, 0))
    if connected?(socket), do: EffectiveDates.subscribe()
    {:ok, socket}
  end

  # handle info
  @impl true
  def handle_info({:save, _params}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
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
        effective_date.id == result.id && result.id == Map.get(Enum.at(effective_dates, 0), :id) ->
          assign(socket, effective_date: Enum.at(effective_dates, 1))
        effective_date.id == result.id ->
          assign(socket, effective_date: Enum.at(effective_dates, 0))
        true -> socket
      end
      |> fetch_effective_dates()
    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end
  # end hadle info

  # handle event
  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, changeset: nil, modal: nil)
    {:noreply, socket}
  end

  def handle_event("search_effective_date", %{"search" => %{"search" => search}}, socket) do
    %{per_page: per_page, weight_break: weight_break} = socket.assigns
    page = 1
    effective_dates = EffectiveDates.list_effective_dates(weight_break, page, per_page, search)
    total_pages = EffectiveDates.total_pages(weight_break, per_page, search)
    socket = assign(socket, update_action: "replace", effective_dates: effective_dates, total_pages: total_pages)
    {:noreply, socket}
  end

  @impl true
  def handle_event("load_more", _, socket) do
    %{page: page, per_page: per_page, search: search, total_pages: total_pages, weight_break: weight_break} = socket.assigns
    page = page + 1
    cond do
      page > total_pages ->
        {:noreply, socket}
      true ->
        effective_dates = EffectiveDates.list_effective_dates(weight_break, page, per_page, search)
        socket = assign(socket, update_action: "append", page: page, effective_dates: effective_dates)
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("new_date", _, socket) do
    changeset =
      EffectiveDates.new_effective_date()
      |> EffectiveDates.change_effective_date()
    socket = assign(socket, modal: :change_date, changeset: changeset)
    {:noreply, socket}
  end

  @impl true
  def handle_event("select_date", %{"id" => id}, socket) do
    %{effective_dates: effective_dates} = socket.assigns
    effective_date = Enum.find(effective_dates, &("#{&1.id}" == id))
    socket = assign(socket, effective_date: effective_date)
    {:noreply, socket}
  end

  @impl true
  def handle_event("pull_update", _params, socket) do
    %{weight_break: weight_break} = socket.assigns
    WeightBreaks.pull_update(weight_break)
    {:noreply, socket}
  end

  @impl true
  def handle_event("copy_modal", _params, socket) do
    changeset =
      EffectiveDates.new_effective_date()
      |> EffectiveDates.change_effective_date()
    socket = assign(socket, modal: :copy_effective_date, changeset: changeset)
    {:noreply, socket}
  end

  @impl true
  def handle_event("change_locked", %{"id" => id}, socket) do
    %{effective_dates: effective_dates} = socket.assigns
    effective_date = Enum.find(effective_dates, &("#{&1.id}" == id))
    EffectiveDates.create_or_update_effective_date(effective_date, %{"locked" => !effective_date.locked})
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    %{effective_dates: effective_dates} = socket.assigns
    effective_date = Enum.find(effective_dates, &("#{&1.id}" == id))
    EffectiveDates.delete_effective_date(effective_date)
    {:noreply, socket}
  end
  # end handle event
end
