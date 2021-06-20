defmodule CustomerAccess.Reports do
  import Ecto.Query
  import Ecto.Changeset

  alias CustomerAccess.{
    Report,
    Repo
  }

  @topic "customer_access:report"

  def subscribe(), do: Phoenix.PubSub.subscribe(CustomerAccess.PubSub, @topic)

  def subscribe(id), do: Phoenix.PubSub.subscribe(CustomerAccess.PubSub, "#{@topic}:#{id}")

  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(CustomerAccess.PubSub, @topic)

  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(CustomerAccess.PubSub, "#{@topic}:#{id}")

  def new_report(), do: %Report{}

  def get_report!(id), do: Repo.get!(Report, id)

  def list_reports() do
    Report
    |> join(:left, [r], rt in assoc(r, :report_type))
    |> preload([r, rt], [:report_type])
    |> order_by(asc: :name)
    |> Repo.all()
  end

  def create_or_update_report(%Report{} = report, attrs \\ %{}) do
    changeset = report
    |> Report.changeset(attrs)

    {_, url} = fetch_field(changeset, :url)

    url = cond do
      String.contains?(url, "decorate=no") -> url
      true -> url <> "&decorate=no"
    end

    url = cond do
      String.contains?(url, "j_password") -> url
      true -> url <> "&j_password=havinfun"
    end

    url = cond do
      String.contains?(url, "j_username") -> url
      true -> url <> "&j_username=customer"
    end

    changeset
    |> change(%{url: url})
    |> Repo.insert_or_update()
    |> notify_subscribers([:report, (if Ecto.get_meta(report, :state) == :built, do: :created, else: :updated)])
  end

  def delete_report(%Report{} = report) do
    Repo.delete(report)
    |> notify_subscribers([:report, :deleted])
  end

  def change_report(%Report{} = report, attrs \\ %{}) do
    Report.changeset(report, attrs)
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(CustomerAccess.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(CustomerAccess.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
