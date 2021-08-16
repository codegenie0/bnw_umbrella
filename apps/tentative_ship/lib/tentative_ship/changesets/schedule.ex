defmodule TentativeShip.Schedule do
  use Ecto.Schema
  import Ecto.Changeset

  alias TentativeShip.{
    Customer,
    Destination,
    LotStatusCode,
    SexCode,
    Yard,
    YardNumber
  }

  prefix = "bnw_dashboard_tentative_ship"
  prefix = case Mix.env do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end
  @schema_prefix prefix

  schema "schedules" do
    field :name, :string
    field :description, :string
    field :active, :boolean, default: true
    field :running_inventory, :boolean, default: false
    field :monitor, :boolean, default: false
    belongs_to :yard, Yard
    many_to_many :customers, Customer, join_through: "schedules_customers", on_replace: :delete
    many_to_many :destinations, Destination, join_through: "schedules_destinations", on_replace: :delete
    many_to_many :lot_status_codes, LotStatusCode, join_through: "schedules_lot_status_codes", on_replace: :delete
    many_to_many :sex_codes, SexCode, join_through: "schedules_sex_codes", on_replace: :delete
    many_to_many :yard_numbers, YardNumber, join_through: "schedules_yard_numbers", on_replace: :delete

    timestamps()
  end

  def changeset(schedule, params \\ %{}) do
    schedule
    |> cast(params, [
      :name,
      :description,
      :active,
      :running_inventory,
      :monitor,
      :yard_id])
    |> validate_required([:name])
    |> unique_constraint(:name, name: :schedules_unique_index)
  end
end
