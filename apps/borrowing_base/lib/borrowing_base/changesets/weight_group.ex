defmodule BorrowingBase.WeightGroup do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias BorrowingBase.{
    EffectiveDate,
    Price,
    Repo,
    WeightBreak,
    Yard
  }

  prefix = "bnw_dashboard_borrowing_base"
  prefix = case Application.get_env(:borrowing_base, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end
  @schema_prefix prefix

  schema "weight_groups" do
    field :min_weight, :integer
    field :max_weight, :integer
    belongs_to :yard, Yard
    belongs_to :effective_date, EffectiveDate
    belongs_to :weight_break, WeightBreak
    has_many :prices, Price, on_replace: :delete

    timestamps()
  end

  def changeset(weight_group, attrs \\ %{}) do
    weight_group
    |> cast(attrs, [:min_weight, :max_weight, :yard_id, :effective_date_id, :weight_break_id])
    |> cast_assoc(:prices, with: &Price.changeset/2)
    |> validate_required([:min_weight, :yard_id, :effective_date_id])
    |> unique_constraint(:weight_group, name: :weight_groups_unique_index)
    |> check_max()
    |> check_range()
  end

  defp check_max(changeset) do
    max = fetch_change(changeset, :max_weight)
    min = fetch_change(changeset, :min_weight)
    {_, max_value} = fetch_field(changeset, :max_weight)
    {_, min_value} = fetch_field(changeset, :min_weight)
    cond do
      changeset.valid? && max != :error && max_value <= min_value ->
        add_error(changeset, :max_weight, "Max Weight must be larger than Min Weight.")
      changeset.valid? && min != :error && max_value <= min_value ->
        add_error(changeset, :max_weight, "Max Weight must be larger than Min Weight.")
      true -> changeset
    end
  end

  defp check_range(changeset) do
    max = fetch_change(changeset, :max_weight)
    min = fetch_change(changeset, :min_weight)
    {_, max_value} = fetch_field(changeset, :max_weight)
    {_, min_value} = fetch_field(changeset, :min_weight)

    cond do
      changeset.valid? && (max != :error || min != :error) ->
        weight_group = changeset.data
        weight_groups = __MODULE__
        |> where([wg], wg.yard_id == ^weight_group.yard_id and
                       wg.effective_date_id == ^weight_group.effective_date_id and
                       wg.id != ^(weight_group.id || 0))
        |> Repo.all()

        range_good = Enum.reduce(weight_groups, true, fn wg, acc ->
          cond do
            acc && max_value && max_value < wg.min_weight -> true
            acc && wg.max_weight && wg.max_weight < min_value -> true
            true -> false
          end
        end)

        cond do
          !range_good ->
            add_error(changeset, :max_weight, "Overlap with another range.")
            |> add_error(:min_weight, "Overlap with another range.")
          true ->
            changeset
        end
      true -> changeset
    end
  end
end
