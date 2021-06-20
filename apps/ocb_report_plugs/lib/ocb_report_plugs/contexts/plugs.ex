defmodule OcbReportPlugs.Plugs do
  @moduledoc """
  Context for the plugs page. This document give functions for applications to interface with the OCB report plugs database.
  """
  alias OcbReportPlugs.{
    Plug,
    Repo
  }

  @topic "ocb_report_plugs:plugs"

  @doc """
  This function subscribes a user to changes in the ocb_report_plugs plugs page.
  This allows for users to get a live update on their role within the application.
  """
  def subscribe(), do: Phoenix.PubSub.subscribe(OcbReportPlugs.PubSub, @topic)
  def subscribe(id), do: Phoenix.PubSub.subscribe(OcbReportPlugs.PubSub, "#{@topic}:#{id}")
  @doc """
  This function unsubscribes a user to changes in the ocb_report_plugs plugs page.
  """
  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(OcbReportPlugs.PubSub, @topic)
  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(OcbReportPlugs.PubSub, "#{@topic}:#{id}")

  @doc """
  Get all plugs from the database.
  """
  def list_plugs() do
    Repo.all(Plug)
  end

  @doc """
  Create a new plug
  """
  def new_plug() do
    %Plug{}
  end
  @doc """
  Get a changeset
  """
  def change_plug(%Plug{} = plug, attrs \\ %{}) do
    Plug.changeset(plug, attrs)
  end

  @doc """
  Validation function used by the modal. Verifies valid date
  """
  def validate(%Plug{} = plug, attrs \\ %{}) do
    plug
      |> change_plug(attrs)
      |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a specifc plug. Called by the create update modal.
  """
  def create_or_update_plug(%Plug{} = plug, attrs \\ %{}) do
    plug
    |> Plug.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:plug, :created_or_updated])
    #(if Ecto.get_meta(plug, :state) == :built, do: :created, else: :updated)])
  end

  @doc """
  Delete a plug then notify others of its departure
  """
  def delete_plug(%Plug{} = plug) do
    Repo.delete(plug)
      |> notify_subscribers([:plug, :deleted])
  end

  @doc """
  Tell everyone who is subscribed about a change.
  """
  def notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(OcbReportPlugs.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(OcbReportPlugs.PubSub, "#{@topic}:#{result.id}", {event, result})

    {:ok, result}
  end
end
