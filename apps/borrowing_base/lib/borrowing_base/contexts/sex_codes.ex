defmodule BorrowingBase.SexCodes do
  import Ecto.Query

  alias BorrowingBase.{
    SexCode,
    Repo
  }

  @topic "borrowing_base:sex_code"

  def subscribe(), do: Phoenix.PubSub.subscribe(BorrowingBase.PubSub, @topic)

  def subscribe(id), do: Phoenix.PubSub.subscribe(BorrowingBase.PubSub, "#{@topic}:#{id}")

  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(BorrowingBase.PubSub, @topic)

  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(BorrowingBase.PubSub, "#{@topic}:#{id}")

  def new_sex_code(%{gender: gender}), do: %SexCode{gender: gender}
  def new_sex_code(), do: %SexCode{}

  def get_sex_code!(id), do: Repo.get!(SexCode, id)

  def list_sex_codes(company_id) do
    SexCode
    |> where([sc], sc.company_id == ^company_id)
    |> order_by([sc], desc: :gender, asc: :sex_code)
    |> Repo.all()
  end

  def list_sex_codes() do
    SexCode
    |> order_by([sc], desc: :gender, asc: :sex_code)
    |> Repo.all()
  end

  def create_or_update_sex_code(%SexCode{} = sex_code, attrs \\ %{}) do
    sex_code
    |> SexCode.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:sex_code, :updated])
  end

  def delete_sex_code(%SexCode{} = sex_code) do
    Repo.delete(sex_code)
    |> notify_subscribers([:sex_code, :deleted])
  end

  def change_sex_code(%SexCode{} = sex_code, attrs \\ %{}) do
    SexCode.changeset(sex_code, attrs)
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(BorrowingBase.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(BorrowingBase.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
