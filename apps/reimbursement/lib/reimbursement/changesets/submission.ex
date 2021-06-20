defmodule Reimbursement.Submission do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_reimbursement"
  prefix = case Application.get_env(:reimbursement, :env) do
             :dev -> prefix <> "_dev"
             :test -> prefix <> "_test"
             _ -> prefix
           end

  @schema_prefix prefix

  schema "submission" do
    field :user_id,   :integer
    field :submitted, :integer
    field :approved,  :integer
    field :month,     :integer
    field :year,      :integer

    timestamps()
  end

  def changeset(submission, attrs \\ %{}) do
    submission
    |> cast(attrs, [
          :user_id,
          :submitted,
          :approved,
          :month,
          :year
        ])
  end
end
