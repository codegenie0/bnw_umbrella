defmodule Reimbursement.Rates do
  @moduledoc """
  Context for the rates data. This document gives access to the current rate per mile based on a date.
  """

  alias Reimbursement.{
    Rate,
    Entries,
    Repo
  }

  import Ecto.Query

  @topic "reimbursement:rates"

  @doc """
  This function subscribes a user to changes in reimbursement rates.
  This allows for users to get a live update on the current rate per mile.
  """
  def subscribe(), do: Phoenix.PubSub.subscribe(Reimbursement.PubSub, @topic)
  def subscribe(id), do: Phoenix.PubSub.subscribe(Reimbursement.PubSub, "#{@topic}:#{id}")
  @doc """
  This function unsubscribes a user to changes in reimbursement rates.
  """
  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(Reimbursement.PubSub, @topic)
  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(Reimbursement.PubSub, "#{@topic}:#{id}")

  @doc """
  Get all entries from the database
  """
  def list_rates() do
    Rate
    |> order_by([rate], desc: rate.year)
    |> Repo.all()
  end

  @doc """
  list the rate for a given date
  """
  def list_rates(date) do
    year = date.year
    val = get_rate(year)
    if !is_nil(val) do
      %{value: val} = val
      val
    else
      0
    end
  end

  @doc """
  Get entry by date
  """
  def get_rate(year) do
    rate = Rate
    |> where([rate], rate.year == ^year)
    |> Repo.one()

    cond do
      rate -> rate
      true -> nil
    end
  end

  @doc """
  Create a new rate
  """
  def new_rate() do
    %Rate{}
  end

  @doc """
  Get a changeset of rate
  """
  def change_rate(%Rate{} = rate, attrs \\ %{}) do
    Rate.changeset(rate, attrs)
  end

  @doc """
  Update rate. Called by the create update modal.
  """
  def create_or_update_rate(%Rate{} = rate, attrs \\ %{}) do
    %{"value" => value} = attrs
    %{year: year}  = rate

    return = rate
    |> Rate.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:rate, :created_or_updated])

    if !is_nil(year) do
      propogate_rate_change(value, year)
    end

    return
  end

  # Recalculate all amounts based on new rate
  defp propogate_rate_change(rate, year) do
    {_, st_date} = Date.new(year, 01, 01)
    {_, en_date} = Date.new(year, 12, 31)

    Entries.list_entries(st_date, en_date)
      |> Enum.map(fn e ->
        Entries.create_or_update_entry(e, %{"rate" => rate})
      end)
  end

  @doc """
  validation function used by the new / edit rate modal.
  Makes sure value > 0
  """
  def validate(%Rate{} = rate, attrs \\ %{}) do
    rate
    |> change_rate(attrs)
    |> Map.put(:action, :insert)
  end

  # Tell everyone who is subscribed about a change.
  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(Reimbursement.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(Reimbursement.PubSub, "#{@topic}:#{result.id}", {event, result})

    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
