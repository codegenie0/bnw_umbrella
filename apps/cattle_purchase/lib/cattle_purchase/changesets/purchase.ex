defmodule CattlePurchase.Purchase do
  use Ecto.Schema
  import Ecto.Changeset

  alias CattlePurchase.{
    DestinationGroup,
    PurchaseType,
    PurchaseBuyer,
    PurchaseGroup,
    PurchaseFlag,
    PurchasePurchaseFlag,
    Shipment,
    Commission,
    DownPayment,
    Repo
  }

  prefix = "bnw_dashboard_cattle_purchase"

  prefix =
    case Application.get_env(:cattle_purchase, :env) do
      :dev -> prefix <> "_dev"
      :test -> prefix <> "_test"
      _ -> prefix
    end

  @schema_prefix prefix

  schema "purchases" do
    field :comment, :string
    field :pasture, :string
    field :purchase_order, :string
    field :pcc_sort, :string
    field :destination_group_name, :string
    field :projected_out_month, :integer
    field :projected_out_year, :integer
    field :freight, :decimal
    field :purchase_date, :date
    field :estimated_ship_date, :date
    field :projected_placement_date, :date
    field :pricing_order_date, :date
    field :customer_fill_date, :date
    field :wcc_fill_date, :date
    field :firm, :boolean, default: false
    field :price_delivered, :boolean, default: false
    field :verify, :boolean, default: false
    field :complete, :boolean, default: false
    belongs_to :destination_group, DestinationGroup

    belongs_to :future_destination_group, DestinationGroup,
      foreign_key: :future_destination_group_id,
      references: :id

    belongs_to :purchase_type, PurchaseType
    belongs_to :purchase_buyer, PurchaseBuyer, foreign_key: :buyer_id
    belongs_to :purchase_group, PurchaseGroup
    has_many(:purchase_purchase_flags, PurchasePurchaseFlag, on_replace: :delete)
    has_many(:shipments, Shipment, on_replace: :delete)
    has_many(:commissions, CattlePurchase.Commission, on_replace: :delete)
    has_many(:down_payments, CattlePurchase.DownPayment, on_replace: :delete)
    has_many(:purchase_details, CattlePurchase.PurchaseDetail, on_replace: :delete)
    many_to_many(:purchase_flags, PurchaseFlag,
      join_through: "purchase_purchase_flags",
      on_delete: :delete_all
    )

    timestamps()
  end

  @required ~w(purchase_date estimated_ship_date freight
                destination_group_id
                purchase_type_id purchase_group_id
              )a
  @optional ~w(firm projected_out_month projected_out_year
                  price_delivered verify complete projected_placement_date
                  comment pasture purchase_order pricing_order_date
                  customer_fill_date wcc_fill_date pcc_sort
                  future_destination_group_id  destination_group_name
                  buyer_id
              )a
  @allowed @required ++ @optional

  def changeset(%__MODULE__{} = model, attrs \\ %{}) do
    model =
      if(model.id != nil,
        do: model |> Repo.preload([:purchase_purchase_flags, :commissions, :down_payments]),
        else: model
      )

    changeset =
      model
      |> cast(attrs, @allowed)
      |> validate_required(@required)
      |> foreign_key_constraint(:destination_group_id)
      |> foreign_key_constraint(:future_destination_group_id)
      |> foreign_key_constraint(:purchase_type_id)
      |> foreign_key_constraint(:buyer_id)
      |> foreign_key_constraint(:purchase_group_id)
      |> cast_assoc(:commissions, with: &Commission.new_changeset/2)
      |> cast_assoc(:down_payments, with: &DownPayment.new_changeset/2)

    if changeset.valid? && attrs["purchase_flag_ids"] && attrs["purchase_flag_ids"] != [] do
      purchase_purchase_flag_params =
        Enum.reduce(attrs["purchase_flag_ids"], [], fn purchase_flag_id, acc ->
          acc ++
            [
              %{
                purchase_flag_id: purchase_flag_id
              }
            ]
        end)

      changeset
      |> Ecto.Changeset.cast(%{purchase_purchase_flags: purchase_purchase_flag_params}, [])
      |> Ecto.Changeset.cast_assoc(:purchase_purchase_flags,
        with: &PurchasePurchaseFlag.changeset_for_purchase_flags/2
      )
    else
      changeset
    end
  end

  def new_changeset(%__MODULE__{} = model, attrs \\ %{}) do
    model
    |> cast(attrs, @allowed)
  end
end
