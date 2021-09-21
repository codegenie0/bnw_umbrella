defmodule CattlePurchase.PurchaseTypeFilter do
  use Ecto.Schema
  import Ecto.Changeset
  alias CattlePurchase.{PurchaseTypePurchaseTypeFilter, Repo}

  prefix = "bnw_dashboard_cattle_purchase"

  prefix =
    case Application.get_env(:cattle_purchase, :env) do
      :dev -> prefix <> "_dev"
      :test -> prefix <> "_test"
      _ -> prefix
    end

  @schema_prefix prefix

  schema "purchase_type_filters" do
    field :name, :string
    field :default_group, :boolean, default: false
    has_many(:purchase_type_purchase_type_filters, PurchaseTypePurchaseTypeFilter, on_replace: :delete)
    many_to_many(:purchase_types, CattlePurchase.PurchaseType , join_through: "purchase_type_purchase_type_filters", on_delete: :delete_all)

    timestamps()
  end

  @required ~w(name)a
  @optional ~w(default_group)a
  @allowed @required ++ @optional

  def changeset(%__MODULE__{} = model, attrs \\ %{}) do
    model = if(model.id != nil,
                do: model |> Repo.preload(:purchase_type_purchase_type_filters),
                else: model)
    changeset =  model
                  |> cast(attrs, @allowed)
                  |> validate_required(@required)

    if changeset.valid? && attrs["purchase_types_ids"] do
        purchase_type_purchase_type_filter_params =    Enum.reduce(attrs["purchase_types_ids"], [], fn purchase_type_id, acc ->
        acc ++
          [
            %{
                purchase_type_id: purchase_type_id
              }
          ]
        end)

        changeset
        |> Ecto.Changeset.cast(%{purchase_type_purchase_type_filters:  purchase_type_purchase_type_filter_params}, [])
        |> Ecto.Changeset.cast_assoc(:purchase_type_purchase_type_filters,
            with: &PurchaseTypePurchaseTypeFilter.changeset_for_purchase_types/2
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
