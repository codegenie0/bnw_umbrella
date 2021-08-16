defmodule PlugsApp.DryMatterSampleItems do

  import Ecto.Query
  alias PlugsApp.{
    DryMatterSampleItem,
    Repo
  }

  @topic "plugs_app:dry_matter_sample_item"


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
  def list_plugs(yard) do
    list_all_plugs(yard)
    |> Enum.map(fn x->
      %{id: id, item: item} = x
      [key: item, value: id]
    end)
  end

  def get_plug(id) do
    %{item: item} = get_plug_struct(id)
    item
  end

  def list_all_plugs(yard) do
    DryMatterSampleItem
    |> where([plug], plug.yard == ^yard)
    |> order_by([plug], asc: plug.item)
    |> Repo.all()
  end

  def get_plug_struct(id) do
    if is_nil(id) do
      %{item: nil}
    else
      plug = DryMatterSampleItem
      |> where([plug], plug.id == ^id)
      |> Repo.one()
      if !is_nil(plug) do
        plug
      else
        %{item: nil}
      end
    end
  end

  def new_plug() do
    %DryMatterSampleItem{}
  end

  def change_plug(%DryMatterSampleItem{} = plug, attrs \\ %{}) do
    DryMatterSampleItem.changeset(plug, attrs)
  end

  @doc """
  Validation function used by the modal. Verifies valid date
  """
  def validate(%DryMatterSampleItem{} = plug, attrs \\ %{}) do
    plug
    |> change_plug(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a specifc plug. Called by the create update modal.
  """
  def create_or_update_plug(%DryMatterSampleItem{} = plug, attrs \\ %{}) do
    plug
    |> DryMatterSampleItem.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:dry_matter_sample_item, :created_or_updated])
  end

  @doc """
  Delete a plug then notify others of its departure
  """
  def delete_plug(%DryMatterSampleItem{} = plug) do
    Repo.delete(plug)
    |> notify_subscribers([:dry_matter_sample_item, :deleted])
  end

  @doc """
  Tell everyone who is subscribed about a change.
  """
  def notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(PlugsApp.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(PlugsApp.PubSub, "#{@topic}:#{result.id}", {event, result})

    {:ok, result}
  end
  def notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
