defmodule BnwDashboardWeb.PlugsApp.DryMatterSample.DryMatterSampleLive do

  use BnwDashboardWeb, :live_view

  alias BnwDashboardWeb.PlugsApp.Helpers.{
    ModalComponent,
    TableLive,
    SearchLive,
    ChangeReportComponent
  }

  alias BnwDashboardWeb.PlugsApp.DryMatterSample.ChangeYardComponent
  alias BnwDashboardWeb.PlugsApp.DryMatterSample.ChangeItemComponent

  alias PlugsApp.{
    DryMatterSamples,
    DryMatterSampleYards,
    DryMatterSampleItems,
    Authorize,
    Reports,
    Users
  }

  defp get_role(socket) do
    current_user = Map.get(socket.assigns, :current_user)
    if current_user do
      Authorize.authorize(current_user, "dry_matter_sample")
    else
      ""
    end
  end

  defp authenticate(socket) do
    case get_role(socket) do
      "admin" -> true
      "edit"  -> true
      "view"  -> true
      _       -> false
    end
  end

  defp fetch_permissions(socket) do
    role = get_role(socket)
    it_admin = socket.assigns.current_user.it_admin
    is_admin = role == "admin"
    is_edit  = role == "admin" or role == "edit"
    assign(socket, it_admin: it_admin, is_admin: is_admin, is_edit: is_edit)
  end

  defp init_args(socket) do
    %{
      selected_item: selected_item,
      items: items
    } = socket.assigns
    args = [
      %{type: :drop_down, special: nil,       name: :item,        display_name: "Item", selected: selected_item, list: items},
      %{type: :date,      special: nil,       name: :sample_date, display_name: "Sample Date"},
      %{type: :number,    special: nil,       name: :pan,         display_name: "Pan", step: 0.1},
      %{type: :number,    special: nil,       name: :wet,         display_name: "Wet", step: 0.1},
      %{type: :number,    special: nil,       name: :dry,         display_name: "Dry", step: 0.1},
      %{type: :number,    special: nil,       name: :target_dm,   display_name: "Target DM", step: 0.1},
    ]

    assign(socket, args: args)
  end

  defp fetch_items(plug) do
    item = Map.get(plug, :item, 0)
    |> DryMatterSampleItems.get_plug()
    Map.put(plug, :item, item)
  end

  defp fetch_plugs(socket) do
    %{
      selected_yard: selected_yard,
      page: page,
      per_page: per_page,
      search: search,
      selected_search_col: search_col
    } = socket.assigns
    pre_plugs = Map.get(socket.assigns, :plugs, [])

    plugs =
      DryMatterSamples.list_plugs(selected_yard, page, per_page, search_col, search)
      |> Enum.map(&(fetch_items(&1)))
      |> Enum.map(&(DryMatterSamples.change_plug(&1)))
    assign(socket, plugs: pre_plugs ++ plugs)
  end

  defp fetch_extra(socket) do
    %{selected_yard: selected_yard} = socket.assigns
    yards = DryMatterSampleYards.list_plugs()
    selected_yard =
    if is_nil(selected_yard) do
      if Enum.count(yards) > 0 do
        Enum.at(yards, 0)[:value]
      else
        0
      end
    else
      selected_yard
    end
    items = DryMatterSampleItems.list_plugs(selected_yard)
    show_yards = Enum.count(yards) > 0
    assign(socket,
      selected_yard: selected_yard,
      yards: yards,
      items: items,
      show_yards: show_yards)
  end

  defp fetch_plug_extra(socket) do
    %{selected_yard: selected_yard} = socket.assigns
    plug_yards = DryMatterSampleYards.list_all_plugs()
    plug_items = DryMatterSampleItems.list_all_plugs(selected_yard)
    assign(socket, plug_yards: plug_yards, plug_items: plug_items)
  end

  defp init_reports(socket) do
    %{plug: plug} = socket.assigns
    reports = Reports.list_reports(plug)

    assign(socket, can_show_reports: Enum.count(reports) > 0, reports: reports)
  end

  @impl true
  def mount(_params, session, socket) do
    page = 1
    per_page = 20
    socket =
      assign_defaults(session, socket)
      |> assign(page_title: "BNW Dashboard · Plugs Dry Matter Samples",
                app: "Plugs",
                add_more: false,
                show_yards: true,
                selected_yard: nil,
                selected_item: 1,
                yards: nil,
                items: nil,
                modal: nil,
                update_action: "replace",
                page: page,
                plug: "dry_matter_sample",
                selected_search_col: :item,
                search: "",
                per_page: per_page)
      |> fetch_extra()
      |> fetch_plugs()
      |> fetch_permissions()
      |> init_args()
      |> init_reports()

    if connected?(socket) do
      DryMatterSamples.subscribe()
      DryMatterSampleYards.subscribe()
      DryMatterSampleItems.subscribe()
      Reports.subscribe()
      Users.subscribe()
    end

    case authenticate(socket) do
      true -> {:ok, socket}
      false -> {:ok, redirect(socket, to: "/")}
    end
  end

  @impl true
  def handle_params(_, _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:dry_matter_sample_item, :created_or_updated], _}, socket) do
    socket = fetch_extra(socket)
    |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:dry_matter_sample_item, :deleted], _}, socket) do
    socket = fetch_extra(socket)
    |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:dry_matter_sample_yard, :created_or_updated], _}, socket) do
    socket = fetch_extra(socket)
    |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:dry_matter_sample_yard, :deleted], _}, socket) do
    socket = fetch_extra(socket)
    |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:dry_matter_sample, :created_or_updated_add_more], _}, socket) do
    changeset =
      DryMatterSamples.new_plug()
      |> DryMatterSamples.change_plug()
    socket = assign(socket,
      changeset: changeset,
      modal: :change_plug,
      modal_title: "New Dry Matter Samples",
      selected_item: 1)
    |> assign(page: 1, plugs: [])
    |> fetch_plugs()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:dry_matter_sample, :created_or_updated], _}, socket) do
    socket = assign(socket, page: 1, plugs: [])
    |> fetch_plugs()
      |> assign(modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:dry_matter_sample, :deleted], _}, socket) do
    socket = assign(socket, page: 1, plugs: [])
    |> fetch_plugs()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:report, :created_or_updated], _}, socket) do
    socket = init_reports(socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:report, :deleted], _}, socket) do
    socket = init_reports(socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:user, :updated], _plug}, socket) do
    case authenticate(socket) do
      true -> {:noreply, fetch_permissions(socket)}
      false -> {:noreply, redirect(socket, to: "/")}
    end
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit_yards", _, socket) do
    socket = assign(socket,
      modal: :change_yard,
      modal_title: "Manage Yards")
      |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit_items", _, socket) do
    socket = assign(socket,
      modal: :change_item,
      modal_title: "Manage Items")
      |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    cur = Enum.find(socket.assigns.plugs, fn u -> u.data.id == id end)
    %{
      items: items
    } = socket.assigns
    item = Enum.find(items, fn x-> x[:key] == cur.data.item end)[:value]

    socket = assign(socket,
      changeset: cur,
      modal: :change_plug,
      modal_title: "Edit Dry Matter Samples",
      selected_item: item)
      |> init_args()
    {:noreply, socket}
  end

  @impl true
  def handle_event("new", _, socket) do
    changeset =
      DryMatterSamples.new_plug()
      |> DryMatterSamples.change_plug()
    socket = assign(socket,
      changeset: changeset,
      modal: :change_plug,
      modal_title: "New Dry Matter Samples",
      selected_item: 1)
      |> init_args()
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, changest: nil, modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_event("set_yard", %{"yard" => yard}, socket) do
    socket = assign(socket, page: 1, selected_yard: String.to_integer(yard), plugs: [])
    |> fetch_extra()
    |> fetch_plugs()
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    cur = Enum.find(socket.assigns.plugs, fn u -> u.data.id == id end)
    DryMatterSamples.delete_plug(cur.data)
    {:noreply, socket}
  end

  def handle_event("save", %{"dry_matter_sample" => plug}, socket) do
    %{
      changeset: changeset,
      add_more: add_more,
      selected_yard: selected_yard
    } = socket.assigns
    plug = Map.put(plug, "yard", selected_yard)

    changeset = DryMatterSamples.validate(changeset.data, plug)
    if changeset.valid? do
      case DryMatterSamples.create_or_update_plug(changeset.data, plug, add_more) do
        {:ok, _plug} ->
          {:noreply, socket}
        {:error, %Ecto.Changeset{} = changest} ->
          {:noreply, assign(socket, changeset: changest)}
      end
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("add_more", _, socket) do
    {:noreply, assign(socket, add_more: true)}
  end

  def handle_event("done", _, socket) do
    {:noreply, assign(socket, add_more: false)}
  end

  def handle_event("validate", %{"dry_matter_sample" => plug}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = DryMatterSamples.validate(changeset.data, plug)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("load_more", _, socket) do
    %{
      page: page
    } = socket.assigns
    page = page + 1
    socket = assign(socket, update_action: "append", page: page)

    {:noreply, fetch_plugs(socket)}
  end

  def handle_event("show_reports", _, socket) do
    {:noreply, assign(socket,
        modal: :show_reports,
        modal_title: "Dry Matter Sample Reports")}
  end

  def handle_event("search", %{"search" => params}, socket) do
    %{
      selected_search_col: prev_col,
      search: prev_search
    } = socket.assigns
    %{
      "search" => search,
      "search_col" => search_col
    } = params

    search_col = String.to_atom(search_col)

    search =
    if prev_col == search_col do
      search
    else
      ""
    end

    socket = assign(socket,
      selected_search_col: search_col,
      search: search
    )

    socket =
    if search_col &&
    (search != "" ||
      prev_search != "") do
      assign(socket, page: 1, plugs: [])
      |> fetch_plugs()
    else
      socket
    end
    {:noreply, socket}
  end
end
