defmodule BnwDashboardWeb.PlugsApp.PackerTysonPricing.PackerTysonPricingLive do

  use BnwDashboardWeb, :live_view

  alias BnwDashboardWeb.PlugsApp.Helpers.{
    ModalComponent,
    TableLive,
    SearchLive,
    ChangeReportComponent
  }
  alias PlugsApp.{
    PackerTysonPricings,
    Authorize,
    Reports,
    Users
  }

  defp get_role(socket) do
    current_user = Map.get(socket.assigns, :current_user)
    if current_user do
      Authorize.authorize(current_user, "tyson_packer")
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
    header = [
      %{name: "", span: 2},
      %{name: "", span: 1},
      %{name: "Regular", span: 14},
      %{name: "", span: 1},
      %{name: "Holsteins", span: 12},
      %{name: "", span: 2},
    ]

    args = [
      %{type: :date,   special: nil,       name: :mpc_week_end_date, display_name: "MPC Week End Date"},
      %{type: :number, special: :currency, name: :usda,              display_name: "USDA", step: 0.01},

      %{type: :filler},

      %{type: :number, special: :currency, name: :reg_tyson_base_price, display_name: "Reg Tyson Base Price", step: 0.01},
      %{type: :number, special: :percent,  name: :reg_plt_yld_percent,  display_name: "PLT YLD%",    step: 0.01},
      %{type: :number, special: :currency, name: :reg_prime,            display_name: "Prime",       step: 0.01},
      %{type: :number, special: :currency, name: :reg_cab,              display_name: "Cab",         step: 0.01},
      %{type: :number, special: :currency, name: :reg_select,           display_name: "Select",      step: 0.01},
      %{type: :number, special: :currency, name: :reg_no_roll,          display_name: "No Roll",     step: 0.01},
      %{type: :number, special: :currency, name: :reg_low_quality,      display_name: "Low Quality", step: 0.01},
      %{type: :number, special: :currency, name: :reg_heiferette,       display_name: "Heiferette",  step: 0.01},
      %{type: :number, special: :currency, name: :reg_yg1,              display_name: "YG1",         step: 0.01},
      %{type: :number, special: :currency, name: :reg_yg2,              display_name: "YG2",         step: 0.01},
      %{type: :number, special: :currency, name: :reg_yg4,              display_name: "YG4",         step: 0.01},
      %{type: :number, special: :currency, name: :reg_yg5,              display_name: "YG5",         step: 0.01},
      %{type: :number, special: :currency, name: :reg_dn_549,           display_name: "549/DN",      step: 0.01},
      %{type: :number, special: :currency, name: :reg_up_1050,          display_name: "1050/UP",     step: 0.01},

      %{type: :filler},

      %{type: :number, special: :currency, name: :hol_base_price,      display_name: "Base Price",  step: 0.01},
      %{type: :number, special: :currency, name: :hol_plt_yld_percent, display_name: "PLT YLD%",    step: 0.01},
      %{type: :number, special: :currency, name: :hol_prime,           display_name: "Prime",       step: 0.01},
      %{type: :number, special: :currency, name: :hol_select,          display_name: "Select",      step: 0.01},
      %{type: :number, special: :currency, name: :hol_no_roll,         display_name: "No Roll",     step: 0.01},
      %{type: :number, special: :currency, name: :hol_low_quality,     display_name: "Low Quality", step: 0.01},
      %{type: :number, special: :currency, name: :hol_yg1,             display_name: "YG1",         step: 0.01},
      %{type: :number, special: :currency, name: :hol_yg2,             display_name: "YG2",         step: 0.01},
      %{type: :number, special: :currency, name: :hol_yg4,             display_name: "YG4",         step: 0.01},
      %{type: :number, special: :currency, name: :hol_yg5,             display_name: "YG5",         step: 0.01},
      %{type: :number, special: :currency, name: :hol_dn_550,          display_name: "550/DN",      step: 0.01},
      %{type: :number, special: :currency, name: :hol_up_1050,         display_name: "1050/UP",     step: 0.01},
    ]

    assign(socket, args: args, header: header)
  end

  defp fetch_plugs(socket) do
    %{
      page: page,
      per_page: per_page,
      search: search,
      selected_search_col: search_col
    } = socket.assigns
    pre_plugs = Map.get(socket.assigns, :plugs, [])

    plugs =
      PackerTysonPricings.list_plugs(page, per_page, search_col, search)
      |> Enum.map(&(PackerTysonPricings.change_plug(&1)))
    assign(socket, plugs: pre_plugs ++ plugs)
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
      |> assign(page_title: "BNW Dashboard · Plugs Packer Tyson Pricing",
                app: "Plugs",
                section: "1",
                modal: nil,
                update_action: "replace",
                page: page,
                plug: "tyson_pricing",
                selected_search_col: :mpc_week_end_date,
                search: "",
                per_page: per_page)
      |> fetch_plugs()
      |> fetch_permissions()
      |> init_args()
      |> init_reports()

    if connected?(socket) do
      PackerTysonPricings.subscribe()
      Reports.subscribe()
      Users.subscribe()
    end

    case authenticate(socket) do
      true -> {:ok, socket}
      false -> {:ok, redirect(socket, to: "/")}
    end
  end

  @impl true
  def handle_info({[:packer_tyson_pricing, :created_or_updated_add_more], _}, socket) do
    changeset =
      PackerTysonPricings.new_plug()
      |> PackerTysonPricings.change_plug
    socket = assign(socket,
      changeset: changeset,
      modal: :change_plug,
      modal_title: "New PackerTysonPricing")
    |> assign(page: 1, plugs: [])
    |> fetch_plugs()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:packer_tyson_pricing, :created_or_updated], _}, socket) do
    socket = assign(socket, page: 1, plugs: [])
    |> fetch_plugs()
      |> assign(modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:packer_tyson_pricing, :deleted], _}, socket) do
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
  def handle_event("edit", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    cur = Enum.find(socket.assigns.plugs, fn u -> u.data.id == id end)
    socket = assign(socket,
      changeset: cur,
      modal: :change_plug,
      modal_title: "Edit PackerTysonPricing")
    |> init_args()
    {:noreply, socket}
  end

  @impl true
  def handle_event("new", _, socket) do
    changeset =
      PackerTysonPricings.new_plug()
      |> PackerTysonPricings.change_plug
    socket = assign(socket,
      changeset: changeset,
      modal: :change_plug,
      modal_title: "New PackerTysonPricing")
    |> init_args()
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, changest: nil, modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    cur = Enum.find(socket.assigns.plugs, fn u -> u.data.id == id end)
    PackerTysonPricings.delete_plug(cur.data)
    {:noreply, socket}
  end

  def handle_event("save", %{"packer_tyson_pricing" => plug}, socket) do
    %{changeset: changeset, add_more: add_more} = socket.assigns

    changeset = PackerTysonPricings.validate(changeset.data, plug)
    if changeset.valid? do
      case PackerTysonPricings.create_or_update_plug(changeset.data, plug, add_more) do
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

  def handle_event("validate", %{"packer_tyson_pricing" => plug}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = PackerTysonPricings.validate(changeset.data, plug)

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
        modal_title: "Tyson Packer Pricing Reports")}
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
