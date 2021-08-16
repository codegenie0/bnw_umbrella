defmodule BnwDashboardWeb.TentativeShip.Yards.Schedules.ScheduleLive do
  use BnwDashboardWeb, :live_view

  alias TentativeShip.Schedules

  @impl true
  def mount(_params, session, socket) do
    %{"parent_pid" => parent_pid, "yard_id" => yard_id, "id" => id} = session
    changeset =
      cond do
        id == 0 ->
          Schedules.new_schedule()
          |> Map.put(:customers, [])
          |> Schedules.change_schedule()
        true ->
          id
          |> Schedules.get_schedule()
          |> Schedules.change_schedule()
      end
    lot_status_codes = Schedules.list_lot_status_codes(changeset.data.id || 0, yard_id)
    sex_codes = Schedules.list_sex_codes(changeset.data.id || 0, yard_id)
    yard_numbers = Schedules.list_yard_numbers(changeset.data.id || 0, yard_id)
    destinations = Schedules.list_destinations(changeset.data.id || 0, yard_id)
    customers =
      changeset.data
      |> Map.get(:customers, [])
      |> Enum.map(&(%{customer_number: &1.customer_number, valid: true}))
      |> Enum.sort(&(String.to_integer(&1.customer_number) <= String.to_integer(&2.customer_number)))
    socket =
      socket
      |> assign(:yard_id, yard_id)
      |> assign(:parent_pid, parent_pid)
      |> assign(:changeset, changeset)
      |> assign(:lot_status_codes, lot_status_codes)
      |> assign(:sex_codes, sex_codes)
      |> assign(:yard_numbers, yard_numbers)
      |> assign(:destinations, destinations)
      |> assign(:customers, customers)
    if connected?(socket), do: Schedules.subscribe(id)
    {:ok, socket}
  end

  # handle info
  @impl true
  def handle_info({[:schedule, :updated], schedule}, socket) do
    %{changeset: changeset} = socket.assigns
    socket = cond do
      changeset.data.id == schedule.id ->
        changeset = Schedules.change_schedule(schedule)
        assign(socket, changeset: changeset)
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
  def handle_event("cancel", _, socket) do
    %{parent_pid: parent_pid, yard_id: yard_id} = socket.assigns
    send(parent_pid, {:save, %{modal: "schedules", yard_id: yard_id}})
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"schedule" => params}, socket) do
    %{changeset: changeset, customers: curr_customers} = socket.assigns
    customers =
      params
      |> Map.get("customers", [])
      |> Enum.map(&(%{customer_number: &1, valid: true}))
    customers =
      cond do
        curr_customers != customers ->
          Enum.map(customers, &Map.put(&1, :valid, Schedules.validate_customer(&1.customer_number)))
        true -> curr_customers
      end
    changeset = Schedules.change_schedule(changeset.data, params)
    |> Map.put(:action, :update)
    socket = assign(socket, changeset: changeset, customers: customers)
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"schedule" => params}, socket) do
    %{
      changeset: changeset,
      parent_pid: parent_pid,
      yard_id: yard_id,
      lot_status_codes: lot_status_codes,
      sex_codes: sex_codes,
      yard_numbers: yard_numbers,
      destinations: destinations,
      customers: customers
    } = socket.assigns

    lot_status_codes_ids =
      lot_status_codes
      |> Enum.filter(&(&1.active))
      |> Enum.map(&(&1.id))

    sex_codes_ids =
      sex_codes
      |> Enum.filter(&(&1.active))
      |> Enum.map(&(&1.id))

    yard_numbers_ids =
      yard_numbers
      |> Enum.filter(&(&1.active))
      |> Enum.map(&(&1.id))

    destinations_ids =
      destinations
      |> Enum.filter(&(&1.active))
      |> Enum.map(&(&1.id))

    customers_ids =
      customers
      |> Enum.filter(&(&1.valid && &1.customer_number != ""))
      |> Enum.map(&(&1.customer_number))
      |> Enum.uniq()

    params =
      params
      |> Map.put("lot_status_codes_ids", lot_status_codes_ids)
      |> Map.put("sex_codes_ids", sex_codes_ids)
      |> Map.put("yard_numbers_ids", yard_numbers_ids)
      |> Map.put("destinations_ids", destinations_ids)
      |> Map.put("customers_ids", customers_ids)
    case Schedules.create_or_update_schedule(changeset.data, params) do
      {:ok, _schedule} ->
        send(parent_pid, {:save, %{modal: "schedules", yard_id: yard_id}})
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, changeset: changeset)
        {:noreply, socket}
    end
  end

  # do this because adding a [] to the name on the checkbox had some odd side effects.
  @impl true
  def handle_event("activate_lot_status_code", %{"id" => id}, socket) do
    %{lot_status_codes: lot_status_codes} = socket.assigns
    lot_status_codes = Enum.map(lot_status_codes, &(if "#{&1.id}" == id, do: Map.put(&1, :active, !&1.active), else: &1))
    socket = assign(socket, :lot_status_codes, lot_status_codes)
    {:noreply, socket}
  end

  @impl true
  def handle_event("activate_sex_code", %{"id" => id}, socket) do
    %{sex_codes: sex_codes} = socket.assigns
    sex_codes = Enum.map(sex_codes, &(if "#{&1.id}" == id, do: Map.put(&1, :active, !&1.active), else: &1))
    socket = assign(socket, :sex_codes, sex_codes)
    {:noreply, socket}
  end

  @impl true
  def handle_event("activate_yard_number", %{"id" => id}, socket) do
    %{yard_numbers: yard_numbers} = socket.assigns
    yard_numbers = Enum.map(yard_numbers, &(if "#{&1.id}" == id, do: Map.put(&1, :active, !&1.active), else: &1))
    socket = assign(socket, :yard_numbers, yard_numbers)
    {:noreply, socket}
  end

  @impl true
  def handle_event("activate_destination", %{"id" => id}, socket) do
    %{destinations: destinations} = socket.assigns
    destinations = Enum.map(destinations, &(if "#{&1.id}" == id, do: Map.put(&1, :active, !&1.active), else: &1))
    socket = assign(socket, :destinations, destinations)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete_customer", %{"id" => id}, socket) do
    %{customers: customers} = socket.assigns
    customers = Enum.reject(customers, &(&1.customer_number == id))
    socket = assign(socket, :customers, customers)
    {:noreply, socket}
  end

  @impl true
  def handle_event("add_customer", _params, socket) do
    %{customers: customers} = socket.assigns
    customers = customers ++ [%{customer_number: "", valid: true}]
    socket = assign(socket, :customers, customers)
    {:noreply, socket}
  end
  # end handle event
end
