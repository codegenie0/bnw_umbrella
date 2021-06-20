defmodule BorrowingBase.LotStatusCodes do
  import Ecto.Query

  alias BorrowingBase.{
    LotStatusCode,
    Repo
  }

  @topic "borrowing_base:lot_status_code"

  def subscribe(), do: Phoenix.PubSub.subscribe(BorrowingBase.PubSub, @topic)

  def subscribe(id), do: Phoenix.PubSub.subscribe(BorrowingBase.PubSub, "#{@topic}:#{id}")

  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(BorrowingBase.PubSub, @topic)

  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(BorrowingBase.PubSub, "#{@topic}:#{id}")

  def new_lot_status_code(), do: %LotStatusCode{}

  def get_lot_status_code!(id), do: Repo.get!(LotStatusCode, id)

  def list_lot_status_codes(company_id) do
    LotStatusCode
    |> where([sc], sc.company_id == ^company_id)
    |> order_by([sc], asc: :lot_status_code)
    |> Repo.all()
  end

  def list_lot_status_codes() do
    LotStatusCode
    |> order_by([sc], asc: :lot_status_code)
    |> Repo.all()
  end

  def create_or_update_lot_status_code(%LotStatusCode{} = lot_status_code, attrs \\ %{}) do
    lot_status_code
    |> LotStatusCode.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:lot_status_code, :updated])
  end

  def delete_lot_status_code(%LotStatusCode{} = lot_status_code) do
    Repo.delete(lot_status_code)
    |> notify_subscribers([:lot_status_code, :deleted])
  end

  def change_lot_status_code(%LotStatusCode{} = lot_status_code, attrs \\ %{}) do
    LotStatusCode.changeset(lot_status_code, attrs)
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(BorrowingBase.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(BorrowingBase.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
