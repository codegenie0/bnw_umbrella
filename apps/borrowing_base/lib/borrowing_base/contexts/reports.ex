defmodule BorrowingBase.Reports do
  import Ecto.Query

  alias BorrowingBase.{
    Repo,
    Report
  }

  @topic "borrowing_base:report"

  def subscribe(), do: Phoenix.PubSub.subscribe(BorrowingBase.PubSub, @topic)

  def subscribe(id), do: Phoenix.PubSub.subscribe(BorrowingBase.PubSub, "#{@topic}:#{id}")

  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(BorrowingBase.PubSub, @topic)

  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(BorrowingBase.PubSub, "#{@topic}:#{id}")

  def new_report(), do: %Report{}

  def get_report!(id), do: Repo.get!(Report, id)

  def list_reports() do
    Report
    |> order_by(asc: :name)
    |> Repo.all()
  end

  def create_or_update_report(%Report{} = report, attrs \\ %{}) do
    report
    |> Report.changeset(attrs)
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
    Phoenix.PubSub.broadcast(BorrowingBase.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(BorrowingBase.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
