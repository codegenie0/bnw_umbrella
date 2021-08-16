defmodule PlugsApp.FourteenDayUsages do

  import Ecto.Query
  alias PlugsApp.{
    FourteenDayUsage,
    Repo
  }

  @topic "plugs_app:fourteen_day_usage"


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
  def list_plugs(yard,
                 page \\ 1,
                 per_page \\ 20,
                 search_col \\ nil,
                 search \\ "") do
    query = FourteenDayUsage
    |> where([plug], plug.yard == ^yard)
    |> order_by([plug], desc: plug.id)
    |> offset(^(per_page * (page - 1)))
    |> limit(^per_page)

    query = cond do
      search_col && search != "" ->
        search = "%#{search}%"
        where(query, [plug], like(field(plug, ^search_col), ^search))
      true -> query
    end

    query
    |> Repo.all()
  end

  def new_plug() do
    %FourteenDayUsage{}
  end

  def change_plug(%FourteenDayUsage{} = plug, attrs \\ %{}) do
    FourteenDayUsage.changeset(plug, attrs)
  end

  @doc """
  Validation function used by the modal. Verifies valid date
  """
  def validate(%FourteenDayUsage{} = plug, attrs \\ %{}) do
    plug
    |> change_plug(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a specifc plug. Called by the create update modal.
  """
  def create_or_update_plug(%FourteenDayUsage{} = plug, attrs \\ %{}, add_more \\ false) do
    plug
      |> FourteenDayUsage.changeset(attrs)
      |> Repo.insert_or_update()
      |> notify_subscribers([:fourteen_day_usage, (if add_more, do: :created_or_updated_add_more, else: :created_or_updated)])
  end

  @doc """
  Delete a plug then notify others of its departure
  """
  def delete_plug(%FourteenDayUsage{} = plug) do
    Repo.delete(plug)
    |> notify_subscribers([:fourteen_day_usage, :deleted])
  end

  def delete_plug(commodity) do
    FourteenDayUsage
    |> where([plug], plug.commodity == ^commodity)
    |> Repo.all()
    |> Enum.map(fn x -> Repo.delete(x) |> notify_subscribers([:fourteen_day_usage, :deleted]) end)
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
