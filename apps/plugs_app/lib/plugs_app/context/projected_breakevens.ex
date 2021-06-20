defmodule PlugsApp.ProjectedBreakevens do

  alias PlugsApp.{
    ProjectedBreakeven,
    Repo
  }

  @topic "plugs_app:projected_breakeven"


  @doc """
  This function subscribes a user to changes in the ocb_report_plugs plugs page.
  This allows for users to get a live update on their role within the application.
  """
  def subscribe(), do: Phoenix.PubSub.subscribe(PlugsApp.PubSub, @topic)
  def subscribe(id), do: Phoenix.PubSub.subscribe(PlugsApp.PubSub, "#{@topic}:#{id}")
  @doc """
  This function unsubscribes a user to changes in the ocb_report_plugs plugs page.
  """
  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(PlugsApp.PubSub, @topic)
  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(PlugsApp.PubSub, "#{@topic}:#{id}")

  @doc """
  Get all plugs from the database.
  """
  def list_plugs() do
    Repo.all(ProjectedBreakeven)
  end

  def new_plug() do
    %ProjectedBreakeven{}
  end

  def change_plug(%ProjectedBreakeven{} = plug, attrs \\ %{}) do
    ProjectedBreakeven.changeset(plug, attrs)
  end

  @doc """
  Validation function used by the modal. Verifies valid date
  """
  def validate(%ProjectedBreakeven{} = plug, attrs \\ %{}) do
    plug
    |> change_plug(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a specifc plug. Called by the create update modal.
  """
  def create_or_update_plug(%ProjectedBreakeven{} = plug, attrs \\ %{}) do
    plug
    |> ProjectedBreakeven.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:projected_breakeven, :created_or_updated])
    #(if Ecto.get_meta(plug, :state) == :built, do: :created, else: :updated)])
  end

  @doc """
  Delete a plug then notify others of its departure
  """
  def delete_plug(%ProjectedBreakeven{} = plug) do
    Repo.delete(plug)
    |> notify_subscribers([:projected_breakeven, :deleted])
  end

  @doc """
  Tell everyone who is subscribed about a change.
  """
  def notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(PlugsApp.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(PlugsApp.PubSub, "#{@topic}:#{result.id}", {event, result})

    {:ok, result}
  end
end
