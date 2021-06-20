defmodule BnwDashboardWeb.BorrowingBase.Home.MarketValueAdjustmentsComponent do
  use BnwDashboardWeb, :live_component

  alias BorrowingBase.MarketValueAdjustments

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    socket = assign(socket, assigns)
    {:ok, socket}
  end

  def preload(list_of_assigns) do
    adjustment_types = ["increment", "percentage", "head", "replace"]
    effective_date =
      list_of_assigns
      |> Enum.find(&(Map.has_key?(&1, :effective_date)))
      |> Map.get(:effective_date)

    genders = MarketValueAdjustments.list_sex_codes(effective_date)

    yard =
      list_of_assigns
      |> Enum.find(&(Map.has_key?(&1, :yard)))
      |> Map.get(:yard)

    lot_status_codes = MarketValueAdjustments.list_lot_status_codes(effective_date)

    adjustments =
      MarketValueAdjustments.list_market_value_adjustments(effective_date.id, yard.id)
      |> Enum.map(fn mva ->
        lscs =
          lot_status_codes
          |> Enum.with_index()
          |> Enum.into(%{}, fn {k, v} -> {v, Enum.find_value(mva.lot_status_codes, false, &(&1.id == k.id))} end)

        g = Enum.into(genders, %{}, fn v -> {v, String.contains?(mva.gender || "", v)} end)

        MarketValueAdjustments.change_market_value_adjustment(mva)
        |> Map.put(:lot_status_codes, lscs)
        |> Map.put(:genders, g)
      end)

    Enum.map(list_of_assigns, fn assigns ->
      assigns
      |> Map.put(:adjustments, adjustments)
      |> Map.put(:lot_status_codes, lot_status_codes)
      |> Map.put(:genders, genders)
      |> Map.put(:adjustment_types, adjustment_types)
    end)
  end

  # handle event
  def handle_event("validate", %{"market_value_adjustment" => params}, socket) do
    %{adjustments: adjustments, genders: genders} = socket.assigns
    %{"index" => i} = params
    i = String.to_integer(i)

    genders_params = Map.get(params, "gender")

    params =
      cond do
        genders_params ->
          g = Enum.reduce(genders_params, "", fn g, acc -> (if acc == "", do: g, else: "#{acc},#{g}") end)
          Map.put(params, "gender", g)
          |> Map.delete("genders")
        true -> params
      end

    adjustments =
      adjustments
      |> Enum.with_index()
      |> Enum.map(fn {k, v} ->
        cond do
          v == i ->
            {lot_status_codes_params, params} = Map.pop(params, "lot_status_codes", %{})

            lot_status_codes =
              Enum.into(k.lot_status_codes, %{}, fn {k, _v} ->
                {k, (if Enum.member?(lot_status_codes_params, "#{k}"), do: true, else: false)}
              end)

            genders =
              Enum.into(genders, %{}, fn g ->
                {g, (if Enum.member?(genders_params || [], g), do: true, else: false)}
              end)

            k.data
            |> MarketValueAdjustments.change_market_value_adjustment(params)
            |> Map.put(:lot_status_codes, lot_status_codes)
            |> Map.put(:genders, genders)
            |> Map.put(:action, :update)

          true -> k
        end
      end)

    socket = assign(socket, adjustments: adjustments)
    {:noreply, socket}
  end

  def handle_event("save", %{"save-type" => params}, socket) do
    %{
        adjustments: adjustments,
        lot_status_codes: lot_status_codes,
        yard: yard,
        effective_date: effective_date,
        weight_break: weight_break
      } = socket.assigns
    adjustments = Enum.map(adjustments, fn adjustment ->
      # find the lot_status_codes that match the ones that are selected and return their ids
      codes = Enum.flat_map(adjustment.lot_status_codes, fn {k, v} ->
        cond do
          # if selected transform
          v ->
            lsc_id =
              lot_status_codes
              |> Enum.at(k)
              |> Map.get(:id)
            [lsc_id]
          # skip
          true -> []
        end
      end)
      Map.put(adjustment, :lot_status_codes, codes)
    end)

    case params do
      "refresh" ->
        MarketValueAdjustments.save_adjustments(adjustments, effective_date, yard, weight_break, true)
      _ ->
        MarketValueAdjustments.save_adjustments(adjustments, effective_date, yard, weight_break, false)
    end

    send self(), {:save, nil}
    {:noreply, socket}
  end

  def handle_event("add", _params, socket) do
    %{adjustments: adjustments, lot_status_codes: lot_status_codes, genders: genders} = socket.assigns
    lot_status_codes =
      lot_status_codes
      |> Enum.with_index()
      |> Enum.into(%{}, fn {_k, v} -> {v, false} end)

    genders = Enum.into(genders, %{}, &({&1, false}))

    mva =
      MarketValueAdjustments.new_market_value_adjustment()
      |> MarketValueAdjustments.change_market_value_adjustment()
      |> Map.put(:lot_status_codes, lot_status_codes)
      |> Map.put(:genders, genders)

    adjustments = adjustments ++ [mva]
    socket = assign(socket, adjustments: adjustments)
    {:noreply, socket}
  end

  def handle_event("delete", %{"index" => i}, socket) do
    %{adjustments: adjustments} = socket.assigns
    i = String.to_integer(i)

    adjustments =
      adjustments
      |> Enum.with_index()
      |> Enum.map(fn {k, v} ->
        cond do
          v == i ->
            k.data
            |> MarketValueAdjustments.change_market_value_adjustment(%{"delete" => true})
            |> Map.put(:lot_status_codes, %{})
            |> Map.put(:action, :delete)
          true -> k
        end
      end)

    socket = assign(socket, adjustments: adjustments)
    {:noreply, socket}
  end
  # end handle event
end
