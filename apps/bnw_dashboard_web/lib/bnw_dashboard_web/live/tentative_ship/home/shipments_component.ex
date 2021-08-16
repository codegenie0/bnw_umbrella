defmodule BnwDashboardWeb.TentativeShip.Home.ShipmentsComponent do
  use BnwDashboardWeb, :live_component

  alias TentativeShip.Lots

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:all_open, true)
      |> assign(:update_action, "replace")
      |> assign(:page, 1)
      |> assign(:per_page, 15)
      |> assign(:search, "")
      |> assign(:total_pages, 1)
      |> assign(:sort, [%{col: "yard_number", dir: "asc", pos: 1}, %{col: "lot_number", dir: "asc", pos: 2}])
    {:ok, socket}
  end

  @impl true
  def update(%{load_more: true}, socket) do
    {:ok, load_more(socket)}
  end

  @impl true
  def update(assigns, socket) do
    %{schedule: schedule} = assigns
    old_schedule = Map.get(socket.assigns, :schedule, %{id: 0})
    socket =
      cond do
        old_schedule.id == schedule.id -> socket
        true ->
          socket
          |> assign(:lots, [])
          |> assign(:search, "")
          |> assign_init()
      end
      |> assign(assigns)
      |> assign_total_pages()
      |> assign_lots()
    {:ok, socket}
  end

  def render_th(col, col_name, sort, target) do
    sort = Enum.find(sort, &(&1.col == col))
    sort_div =
      cond do
        sort ->
          dir = if sort.dir == "asc", do: "triangle-up", else: "triangle-down"
          """
            <div class="uk-margin-small-left">
              <span class="uk-preserve-width" uk-icon="#{dir}" phx-hook="uk_icon"></span>
              <span class="uk-badge">#{sort.pos}</span>
            </div>
          """
        true -> ""
      end

    """
      <th class="uk-background-secondary uk-text-center">
        <a class="uk-text-muted" href="#" phx-click="sort" phx-target="#{target}" phx-value-col="#{col}">
          <div class="uk-flex uk-flex-inline">
            <div>#{col_name}</div>
            #{sort_div}
          </div>
        </a>
      </th>
    """
  end

  defp assign_init(socket) do
    socket
    |> assign(:update_action, "replace")
    |> assign(:page, 1)
    |> assign(:per_page, 15)
  end

  defp assign_total_pages(socket) do
    %{
      schedule: schedule,
      per_page: per_page,
      search: search
    } = socket.assigns
    total_pages = Lots.get_lots_data_total_pages(schedule.id, per_page, search)
    assign(socket, :total_pages, total_pages)
  end

  defp assign_lots(socket) do
    %{
      page: page,
      per_page: per_page,
      search: search,
      schedule: schedule,
      all_open: all_open,
      sort: sort,
      update_action: update_action
    } = socket.assigns
    new_lots = Lots.get_lots_data(schedule.id, page, per_page, search, sort)
    lots =
      cond do
        all_open && update_action == "append" ->
          Map.get(socket.assigns, :lots, []) ++ new_lots
        all_open ->
          new_lots
        update_action == "append" ->
          Map.get(socket.assigns, :lots, []) ++ Enum.map(new_lots, &Map.put(&1, :open, false))
        true ->
          Enum.map(new_lots, &Map.put(&1, :open, false))
      end

    assign(socket, :lots, lots)
  end

  defp load_more(socket) do
    %{
      page: page,
      total_pages: total_pages
    } = socket.assigns

    cond do
      page < total_pages ->
        socket
        |> assign(:page, page + 1)
        |> assign(:update_action, "append")
        |> assign_lots()
      true -> socket
    end
  end

  @impl true
  def handle_event("open_all", _, socket) do
    %{all_open: all_open, lots: lots} = socket.assigns
    all_open = !all_open
    lots = Enum.map(lots, &Map.put(&1, :open, all_open))
    socket =
      socket
      |> assign(:lots, lots)
      |> assign(:all_open, all_open)
      |> assign_init()
      |> assign_lots()
    {:noreply, socket}
  end

  @impl true
  def handle_event("open", %{"id" => id}, socket) do
    %{lots: lots} = socket.assigns
    lots = Enum.map(lots, &(
      cond do
        to_string(&1.id) == id -> Map.put(&1, :open, !&1.open)
        true -> &1
      end
    ))
    socket = assign(socket, :lots, lots)
    {:noreply, socket}
  end

  def handle_event("search_lots", %{"search" => %{"search" => search}}, socket) do
    socket =
      socket
      |> assign(:lots, [])
      |> assign(:search, search)
      |> assign_init()
      |> assign_total_pages()
      |> assign_lots()
    {:noreply, socket}
  end

  def handle_event("sort", %{"col" => col_name}, socket) do
    %{sort: sort} = socket.assigns
    col = Enum.find(sort, &(&1.col == col_name))

    sort =
      cond do
        col && col.dir == "asc" -> # switch dir to desc
          Enum.map(sort, &(if &1.col == col_name, do: Map.put(&1, :dir, "desc"), else: &1))
        col -> # remove col
          sort
          |> Enum.reject(&(&1.col == col_name))
          |> Enum.map(&(if &1.pos > col.pos, do: Map.put(&1, :pos, &1.pos - 1), else: &1))
        true -> # add col
          max_pos = Enum.at(sort, -1, %{pos: 0})
          sort ++ [%{col: col_name, dir: "asc", pos: max_pos.pos + 1}]
      end

    socket =
      socket
      |> assign(:sort, sort)
      |> assign_init()
      |> assign_lots()
    {:noreply, socket}
  end
end
