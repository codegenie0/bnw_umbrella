defmodule CattlePurchase.Payee do
  use Ecto.Schema
  import Ecto.Changeset
  alias CattlePurchase.PurchasePayee

  prefix = "bnw_dashboard_cattle_purchase"

  prefix =
    case Mix.env() do
      :dev -> prefix <> "_dev"
      :test -> prefix <> "_test"
      _ -> prefix
    end

  @schema_prefix prefix
  @primary_key {:id, :string, []}
  schema "payees" do
    field :name, :string
    field :vendor_number, :string
    field :lienholder, :string
    field :address1, :string
    field :address2, :string
    field :city, :string
    field :state, :string
    field :zip, :string
    field :phone, :string
    field :contact_name, :string
    field :comments, :string

    has_one :purchase_payee, PurchasePayee
    has_one :purchase, through: [:purchase_payee, :purchase]
  end

  def changeset(payee, params \\ %{}) do
    payee
    |> cast(params, [
      :id,
      :name,
      :vendor_number,
      :lienholder,
      :address1,
      :address2,
      :city,
      :state,
      :zip,
      :phone,
      :contact_name,
      :comments
    ])
    |> validate_required([:name, :vendor_number])
    |> unique_constraint(:vendor_number, name: :payee_number_unique_index)
  end
end
