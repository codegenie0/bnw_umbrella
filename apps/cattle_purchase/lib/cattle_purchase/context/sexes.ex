defmodule CattlePurchase.Sexes do
  alias CattlePurchase.{
    Sex,
    PriceSheets,
    Repo
  }

  import Ecto.Query, only: [from: 2]
  @topic "cattle_purchase:sexes"

  def subscribe(), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, @topic)
  def subscribe(id), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")
  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, @topic)
  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")

  @doc """
  List all active sexes
  """
  def get_active_sexes() do
    from(p in Sex,
      where: p.active == true
    )
    |> Repo.all()
  end

  @doc """
  List all inactive sexes
  """
  def get_inactive_sexes() do
    from(p in Sex,
      where: p.active == false
    )
    |> Repo.all()
  end

  @doc """
  Create a new sex
  """
  def new_sex() do
    Sex.new_changeset(%Sex{}, %{})
  end

  def change_sex(%Sex{} = sex, attrs \\ %{}) do
    Sex.changeset(sex, attrs)
  end

  def validate(%Sex{} = sex, attrs \\ %{}) do
    sex
    |> change_sex(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a purchase_type
  """
  def create_or_update_sex(%Sex{} = sex, attrs \\ %{}) do
    sex
    |> Sex.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:sexes, :created_or_updated])
  end

  def update_price_sheets(sex) do
    new_price_sheet_detail =
      Enum.map(PriceSheets.get_weight_categories_for_create(), fn wc ->
        %{weight_category_id: wc, sex_id: sex.id}
      end)

    price_sheets = CattlePurchase.Repo.all(CattlePurchase.PriceSheet)

    if price_sheets != [] do
      Enum.map(price_sheets, fn ps ->
        ps = ps |> Repo.preload(:price_sheet_details)

        price_sheet_detail_list =
          Enum.map(ps.price_sheet_details, fn psd ->
            %{weight_category_id: psd.weight_category_id, sex_id: psd.sex_id, value: psd.value}
          end)

        price_sheet_details = price_sheet_detail_list ++ new_price_sheet_detail
        Ecto.Changeset.change(ps, price_sheet_details: price_sheet_details) |> Repo.update()
      end)
    end
  end

  @doc """
  Delete a sex
  """
  def delete_sex(%Sex{} = sex) do
    Repo.delete(sex)
    |> notify_subscribers([:sexes, :deleted])
  end

  def notify_subscribers({:ok, result}, event) do
    if result.inserted_at == result.updated_at do
      Task.start_link(fn -> update_price_sheets(result) end)
    end

    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, "#{@topic}:#{result.id}", {event, result})

    {:ok, result}
  end

  def notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
