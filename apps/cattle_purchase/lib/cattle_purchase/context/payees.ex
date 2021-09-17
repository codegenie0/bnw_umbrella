defmodule CattlePurchase.Payees do
  import Ecto.Query

  alias CattlePurchase.{
    Payee,
    Repo
  }

  @topic "cattle_purchase:payees"

  def subscribe(), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, @topic)

  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, @topic)

  def get_payee!(id), do: Repo.get!(Payee, id)

  def list_payees(current_page \\ 1, per_page \\ 10, search \\ "") do
    search = "%#{search}%"
    Payee
    |> where([p], like(p.name, ^search) or
                  like(p.vendor_number, ^search) or
                  like(p.lienholder, ^search))
    |> order_by([p], fragment("cast(? as unsigned)", p.vendor_number))
    |> offset(^(per_page * (current_page - 1)))
    |> limit(^per_page)
    |> Repo.all()
  end

  def total_pages(per_page \\ 10, search \\ "") do
    search = "%#{search}%"
    payee_count =
      Payee
      |> where([p], like(p.name, ^search) or
                    like(p.vendor_number, ^search) or
                    like(p.lienholder, ^search))
      |> Repo.aggregate(:count, :id)

    (payee_count / per_page)
    |> Decimal.from_float()
    |> Decimal.round(0, :up)
    |> Decimal.to_integer()
  end


  def change_payee(%Payee{} = payee, attrs \\ %{}) do
    Payee.changeset(payee, attrs)
  end

  # Update all payees from turnkey.
  # Payee.id is Turnkey's vendor_number
  def update_payees() do
    new_payees = new_payees()
    updated_payees = updated_payees()
    deleted_payees = deleted_payees()
    delete_query = from(p in Payee, where: p.id in ^deleted_payees)

    Enum.reduce(updated_payees, Ecto.Multi.new(), fn p, multi ->
      Ecto.Multi.update(multi, {:payee, p.payee.id}, change_payee(p.payee, %{"name" => p.new_name, "lienholder" => p.new_lienholder}))
    end)
    |> Ecto.Multi.insert_all(:insert_all, Payee, new_payees)
    |> Ecto.Multi.delete_all(:delete_all, delete_query)
    |> Repo.transaction()
    |> notify_subscribers([:payees, :updated])
  end

  defp new_payees() do
    from(tkv in "venmas")
    |> join(:left, [tkv], p in Payee, on: tkv.vendor_number == p.vendor_number)
    |> where([tkv, p], tkv.yard == ^"nls" and is_nil(p.id))
    |> select([tkv, p], %{
      id: tkv.vendor_number,
      name: tkv.name,
      vendor_number: tkv.vendor_number,
      lienholder: fragment("if((right(?, 1) = '&' or right(rtrim(?), 4) = ' and'), ?, null)", tkv.name, tkv.name, tkv.address1)
    })
    |> Repo.Turnkey.all()
    |> Enum.map(&(%{id: &1.id, name: &1.name, vendor_number: "#{&1.vendor_number}", lienholder: &1.lienholder}))
  end

  defp updated_payees() do
    from(tkv in "venmas")
    |> join(:left, [tkv], p in Payee, on: tkv.vendor_number == p.vendor_number)
    |> where([tkv, p], tkv.yard == ^"nls" and not is_nil(p.id))
    |> select([tkv, p], %{
      new_name: tkv.name,
      new_lienholder: fragment("if((right(?, 1) = '&' or right(rtrim(?), 4) = ' and'), ?, null)", tkv.name, tkv.name, tkv.address1),
      payee: %Payee{
        id: tkv.vendor_number,
        name: p.name,
        vendor_number: tkv.vendor_number,
        lienholder: p.lienholder
      }
    })
    |> Repo.Turnkey.all()
  end

  defp deleted_payees() do
    from(tkv in "venmas")
    |> join(:right, [tkv], p in Payee,
      on: tkv.vendor_number == p.vendor_number and tkv.yard == ^"nls")
    |> where([tkv, p], is_nil(tkv.vendor_number))
    |> select([tkv, p], p.id)
    |> Repo.Turnkey.all()
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, @topic, {event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
