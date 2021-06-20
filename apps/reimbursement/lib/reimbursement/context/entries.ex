defmodule Reimbursement.Entries do
  @moduledoc """
  Context for the entries page. This document give functions for applications to interface with the Reimbursement entries database.
  """

  import Ecto.Query
  alias Reimbursement.{
    Entry,
    Repo
  }

  @topic "reimbursement:entries"

  @doc """
  This function subscribes a user to changes in the reimbursement entries page.
  This allows for users to get a live update on their role within the application.
  """
  def subscribe(), do: Phoenix.PubSub.subscribe(Reimbursement.PubSub, @topic)
  def subscribe(id), do: Phoenix.PubSub.subscribe(Reimbursement.PubSub, "#{@topic}:#{id}")
  @doc """
  This function unsubscribes a user to changes in the reimbursement entries page.
  """
  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(Reimbursement.PubSub, @topic)
  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(Reimbursement.PubSub, "#{@topic}:#{id}")

  @doc """
  Get all entries from the database.
  """
  def list_all_entries() do
    Entry
    |> order_by([entry], desc: entry.entry_date)
    |> Repo.all()
  end

  @doc """
  Get all entries from the database in date range.
  """
  def list_entries(st_date, en_date) do
    Entry
    |> where([reimbursement_entry],
      reimbursement_entry.entry_date >= ^st_date
      and reimbursement_entry.entry_date <= ^en_date)
    |> order_by([entry], desc: entry.entry_date)
    |> Repo.all()
  end

  @doc """
  Check what radio option was selected when this entry was created
  """
  def get_radio(id) do
    Entry
    |> where([entry], entry.id == ^id)
    |> Repo.one()
  end

  @doc """
  Create a new entry
  """
  def new_entry() do
    %Entry{}
  end
  @doc """
  Get a changeset
  """
  def change_entry(%Entry{} = entry, attrs \\ %{}) do
    Entry.changeset(entry, attrs)
  end

  @doc """
  Validation function used by the modal. Verifies valid date
  """
  def validate(%Entry{} = entry, attrs \\ %{}) do
    entry
      |> change_entry(attrs)
      |> Map.put(:action, :insert)
  end

  @doc """
  Select all years that are being used
  """
  def get_used_years() do
    Entry
    |> distinct(true)
    |> select([entry], {entry.entry_date})
    |> Repo.all()
  end

  @doc """
  Create or update a specific entry. Called by the create update modal.
  """
  def create_or_update_entry(%Entry{} = entry, attrs \\ %{}) do
    entry
    |> Entry.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:entry, :created_or_updated])
  end

  @doc """
  Delete a entry then notify others of its departure
  """
  def delete_entry(%Entry{} = entry) do
    Repo.delete(entry)
      |> notify_subscribers([:entry, :delete])
  end

  # Tell everyone who is subscribed about a change.
  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(Reimbursement.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(Reimbursement.PubSub, "#{@topic}:#{result.id}", {event, result})

    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
