defmodule TentativeShip.Schedules do
  import Ecto.Query

  alias TentativeShip.{
    LotStatusCode,
    SexCode,
    YardNumber,
    Destination,
    Customer,
    Schedule,
    Repo
  }

  @topic "tentative_ship:schedules"

  def subscribe(), do: Phoenix.PubSub.subscribe(TentativeShip.PubSub, @topic)

  def subscribe(id), do: Phoenix.PubSub.subscribe(TentativeShip.PubSub, "#{@topic}:#{id}")

  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(TentativeShip.PubSub, @topic)

  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(TentativeShip.PubSub, "#{@topic}:#{id}")

  def new_schedule(), do: %Schedule{}

  def get_schedule(id) do
    Schedule
    |> Repo.get(id)
    |> Repo.preload(:lot_status_codes)
    |> Repo.preload(:sex_codes)
    |> Repo.preload(:yard_numbers)
    |> Repo.preload(:destinations)
    |> Repo.preload(:customers)
  end

  def get_schedule!(id), do: Repo.get!(Schedule, id)

  def list_schedules(yard_id) do
    Schedule
    |> where([sc], sc.yard_id == ^yard_id)
    |> order_by([sc], desc: fragment("field(?, 'all')", sc.name))
    |> Repo.all()
  end

  def list_active_schedules(yard_id) do
    Schedule
    |> where([sc], sc.yard_id == ^yard_id and sc.active)
    |> order_by([sc], desc: fragment("field(?, 'all')", sc.name))
    |> Repo.all()
  end

  def create_or_update_schedule(%Schedule{} = schedule, attrs \\ %{}) do
    lot_status_codes_ids = Map.get(attrs, "lot_status_codes_ids", [])
    lot_status_codes =
      LotStatusCode
      |> where([lsc], lsc.id in ^lot_status_codes_ids)
      |> Repo.all()

    sex_codes_ids = Map.get(attrs, "sex_codes_ids", [])
    sex_codes =
      SexCode
      |> where([sc], sc.id in ^sex_codes_ids)
      |> Repo.all()

    yard_numbers_ids = Map.get(attrs, "yard_numbers_ids", [])
    yard_numbers =
      YardNumber
      |> where([yn], yn.id in ^yard_numbers_ids)
      |> Repo.all()

    destinations_ids = Map.get(attrs, "destinations_ids", [])
    destinations =
      Destination
      |> where([d], d.id in ^destinations_ids)
      |> Repo.all()

    customers_ids = Map.get(attrs, "customers_ids", [])
    customers =
      Customer
      |> where([c], c.id in ^customers_ids)
      |> Repo.all()

    schedule
    |> Schedule.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:lot_status_codes, lot_status_codes)
    |> Ecto.Changeset.put_assoc(:sex_codes, sex_codes)
    |> Ecto.Changeset.put_assoc(:yard_numbers, yard_numbers)
    |> Ecto.Changeset.put_assoc(:destinations, destinations)
    |> Ecto.Changeset.put_assoc(:customers, customers)
    |> Repo.insert_or_update()
    |> notify_subscribers([:schedule, (if Ecto.get_meta(schedule, :state) == :built, do: :created, else: :updated)])
  end

  def delete_schedule(%Schedule{} = schedule) do
    Repo.delete(schedule)
    |> notify_subscribers([:schedule, :deleted])
  end

  def change_schedule(%Schedule{} = schedule, attrs \\ %{}) do
    Schedule.changeset(schedule, attrs)
  end

  def list_lot_status_codes(schedule_id, yard_id) do
    LotStatusCode
    |> join(:left, [l], s in "schedules_lot_status_codes",
      on: l.id == s.lot_status_code_id and s.schedule_id == ^schedule_id)
    |> where([l, s], l.yard_id == ^yard_id)
    |> select([l, s], %{id: l.id, name: l.name, description: l.description, active: not is_nil(s.id)})
    |> order_by([l, s], asc: l.name)
    |> Repo.all()
  end

  def list_sex_codes(schedule_id, yard_id) do
    SexCode
    |> join(:left, [sc], s in "schedules_sex_codes",
      on: sc.id == s.sex_code_id and s.schedule_id == ^schedule_id)
    |> where([sc, s], sc.yard_id == ^yard_id)
    |> select([sc, s], %{id: sc.id, name: sc.name, description: sc.description, active: not is_nil(s.id)})
    |> order_by([sc, s], asc: sc.name)
    |> Repo.all()
  end

  def list_yard_numbers(schedule_id, yard_id) do
    YardNumber
    |> join(:left, [yn], s in "schedules_yard_numbers",
      on: yn.id == s.yard_number_id and s.schedule_id == ^schedule_id)
    |> where([yn, s], yn.yard_id == ^yard_id)
    |> select([yn, s], %{id: yn.id, name: yn.name, description: yn.description, active: not is_nil(s.id)})
    |> order_by([yn, s], asc: yn.name)
    |> Repo.all()
  end

  def list_destinations(schedule_id, yard_id) do
    Destination
    |> join(:left, [d], s in "schedules_destinations",
      on: d.id == s.destination_id and s.schedule_id == ^schedule_id)
    |> where([d, s], d.yard_id == ^yard_id)
    |> select([d, s], %{id: d.id, name: d.name, description: d.description, active: not is_nil(s.id)})
    |> order_by([d, s], asc: d.name)
    |> Repo.all()
  end

  def validate_customer(customer_number) do
    cond do
      customer_number == "" -> true
      is_nil(customer_number) -> true
      Repo.get(Customer, customer_number) -> true
      true -> false
    end
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(TentativeShip.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(TentativeShip.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
