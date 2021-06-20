defmodule CustomerAccess.ReportTypes do
  import Ecto.Query

  alias CustomerAccess.{
    ReportType,
    Repo
  }

  @topic "customer_access:report_type"

  def subscribe(), do: Phoenix.PubSub.subscribe(CustomerAccess.PubSub, @topic)

  def subscribe(id), do: Phoenix.PubSub.subscribe(CustomerAccess.PubSub, "#{@topic}:#{id}")

  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(CustomerAccess.PubSub, @topic)

  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(CustomerAccess.PubSub, "#{@topic}:#{id}")

  def new_report_type(), do: %ReportType{}

  def get_report_type!(id), do: Repo.get!(ReportType, id)

  def list_report_types() do
    ReportType
    |> order_by(asc: :name)
    |> Repo.all()
  end

  def create_or_update_report_type(%ReportType{} = report_type, attrs \\ %{}) do
    report_type
    |> ReportType.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:report_type, :updated])
  end

  def delete_report_type(%ReportType{} = report_type) do
    Repo.delete(report_type)
    |> notify_subscribers([:report_type, :updated])
  end

  def change_report_type(%ReportType{} = report_type, attrs \\ %{}) do
    ReportType.changeset(report_type, attrs)
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(CustomerAccess.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(CustomerAccess.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
