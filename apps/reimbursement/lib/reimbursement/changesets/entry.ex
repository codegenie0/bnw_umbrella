defmodule Reimbursement.Entry do
  use Ecto.Schema
  import Ecto.Changeset

  alias Reimbursement.{
    Rates,
    Submissions
  }

  prefix = "bnw_dashboard_reimbursement"
  prefix = case Application.get_env(:reimbursement, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end

  @schema_prefix prefix

  schema "reimbursement_entry" do
    field :user_id,       :integer
    field :desc,          :string
    field :entry_date,    :date
    field :radio,         :integer
    field :start_mileage, :decimal
    field :end_mileage,   :decimal
    field :mileage,       :decimal
    field :rate,          :decimal
    field :amount,        :decimal
    field :misc_amount,   :decimal
    field :amount_tot,    :decimal
  end

  def changeset(entry, attrs \\ %{}) do
    entry
    |> cast(attrs, [
      :user_id,
      :desc,
      :entry_date,
      :radio,
      :start_mileage,
      :end_mileage,
      :mileage,
      :rate,
      :amount,
      :misc_amount,
      :amount_tot])
    |> validate_date()
    |> calculate_mileage()
    |> calculate_amount()
  end


  # create a new private function
  # look at users
  # feed it a changeset
  # extract values
  # do calculation
  # put that back into the changeset
  # return changeset

  # check if the date is valid
  def validate_date(changeset) do
    # get fields
    entry_date   = fetch_change(changeset, :entry_date)
    {_, user_id} = fetch_field(changeset, :user_id)

    # if the changed date does not exist ignore
    # this is important for rate propagation
    if !is_nil(entry_date) && entry_date != :error do
      {_, entry_date} = entry_date
      # extract month and year from the date
      month = entry_date.month
      year  = entry_date.year
      # check for submission
      submitted = Submissions.get_submission(user_id, month, year)
      # check rate for time frame
      rate = Rates.list_rates(entry_date)
      cond do
        # if a rate does not exist for the time frame
        # then the date is invalid
        rate == 0 ->
          add_error(
            changeset,
            :entry_date,
            "Invalid Date #{entry_date} - No rate exists")
        # if the submission for the time frame is non zero
        # then the date is invalid
        submitted.sub != 0 ->
          add_error(
            changeset,
            :entry_date,
            "Invalid Date #{entry_date} - Already submitted")
        # if both those conditions are not true
        # then the date is valid
        true ->
          changeset
      end
    else
      # ignore if the date is unchanged
      changeset
    end
  end

  # calculate miles driven
  defp calculate_mileage(changeset) do
    # get fields
    {_, start_mileage} = fetch_field(changeset, :start_mileage)
    {_, end_mileage}   = fetch_field(changeset, :end_mileage)


    # calculate mileage
    cond do
      # start and end mileage is odometer reading
      start_mileage && end_mileage ->
        change(changeset, %{mileage: Decimal.sub(end_mileage, start_mileage)})
      # just end mileage is mileage entry
      end_mileage ->
        change(changeset, %{mileage: end_mileage})
      # set to zero if ending mileage is nil
      true ->
        change(changeset, %{mileage: 0})
    end
  end

  # calculate amount owed
  defp calculate_amount(changeset) do
    # get fields
    {_, mileage}    = fetch_field(changeset, :mileage)
    {_, entry_date} = fetch_field(changeset, :entry_date)
    {_, misc}       = fetch_field(changeset, :misc_amount)

    # get rate for time period
    changeset = cond do
      # if the date exists use it
      entry_date ->
        # set the rate in the changeset
        change(changeset, %{rate: Rates.list_rates(entry_date)})
      # if the date does not exist
      # use today
      true ->
        # set the rate in the changeset
        change(changeset, %{rate: Rates.list_rates(DateTime.utc_now()), entry_date: DateTime.utc_now()})
    end

    # get rate
    {_, rate} = fetch_field(changeset, :rate)

    # calculate amount
    cond do
      mileage && misc ->
        change(changeset, %{amount: Decimal.mult(mileage, rate), amount_tot: Decimal.add(Decimal.mult(mileage, rate), misc)})
      mileage ->
        change(changeset, %{amount: Decimal.mult(mileage, rate), amount_tot: Decimal.mult(mileage, rate)})
      misc ->
        change(changeset, %{amount: 0, amount_tot: misc})
      true ->
        change(changeset, %{amount: 0, amount_tot: 0})
    end
  end

end
