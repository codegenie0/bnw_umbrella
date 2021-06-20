defmodule CihReportPlugs.Plugs do

  alias CihReportPlugs.{
    Plug,
    Repo
  }

  @topic "cih_report_plugs:plugs"

  def subscribe(), do: Phoenix.PubSub.subscribe(CihReportPlugs.PubSub, @topic)
  def subscribe(id), do: Phoenix.PubSub.subscribe(CihReportPlugs.PubSub, "#{@topic}:#{id}")
  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(CihReportPlugs.PubSub, @topic)
  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(CihReportPlugs.PubSub, "#{@topic}:#{id}")

  def list_plugs() do
    Repo.all(Plug)
#    query = where(Plug, [plug])
  end

  @doc """
  Create a new plug
  """
  def new_plug() do
    %Plug{}
  end

  def change_plug(%Plug{} = plug, attrs \\ %{}) do
    Plug.changeset(plug, attrs)
  end

  def validate(%Plug{} = plug, attrs \\ %{}) do
    plug
      |> change_plug(attrs)
      |> Map.put(:action, :insert)
  end

  #update -> external_application.create_or_update
  #send updateed data
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

  def notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(CihReportPlugs.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(CihReportPlugs.PubSub, "#{@topic}:#{result.id}", {event, result})

    {:ok, result}
  end

  def notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
