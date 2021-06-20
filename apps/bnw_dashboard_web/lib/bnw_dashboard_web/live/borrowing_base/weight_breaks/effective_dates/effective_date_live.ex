defmodule BnwDashboardWeb.BorrowingBase.WeightBreaks.EffectiveDates.EffectiveDateLive do
  use BnwDashboardWeb, :live_view

  alias BorrowingBase.{
    EffectiveDates,
    SexCodes,
    WeightGroups,
    Yards
  }
  alias BnwDashboardWeb.BorrowingBase.WeightBreaks.EffectiveDates.{
    NewWeightGroupComponent,
    WeightGroupLive
  }


  defp fetch_weight_groups(socket) do
    %{yard: yard, effective_date: effective_date} = socket.assigns
    weight_groups = WeightGroups.list_weight_groups(yard.id, effective_date.id)
    genders =
      SexCodes.list_sex_codes(yard.company_id)
      |> Enum.map(&(&1.gender))
      |> Enum.uniq()
      |> Enum.sort(&(
        cond do
          &1 == "steer" -> true
          &2 == "steer" -> false
          &1 == "heifer" -> true
          &2 == "heifer" -> false
          true -> &1 <= &2
        end
      ))
    assign(socket, weight_groups: weight_groups, genders: genders)
  end

  @impl true
  def mount(_params, session, socket) do
    %{
      "effective_date" => effective_date,
      "weight_break" => weight_break
    } = session
    yards = Yards.list_yards(weight_break.company_id)
    yard = Enum.at(yards, 0)
    socket =
      assign(socket, yards: yards, yard: yard, modal: nil, changeset: nil, effective_date: effective_date, weight_break: weight_break)
      |> fetch_weight_groups()
    if connected?(socket) do
      EffectiveDates.subscribe()
      WeightGroups.subscribe()
      Yards.subscribe()
    end
    {:ok, socket}
  end

  # handle params
  # end handle params

  # handle info
  @impl true
  def handle_info({:save, _params}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:yard, _action], yard}, socket) do
    %{weight_break: weight_break} = socket.assigns
    socket = cond do
      yard.company_id == weight_break.company_id ->
        assign(socket, yards: Yards.list_yards(weight_break.company_id))
      true -> socket
    end
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:weight_group, :deleted], deleted_weight_group}, socket) do
    %{weight_groups: weight_groups} = socket.assigns
    weight_groups = Enum.reject(weight_groups, &(&1.id == deleted_weight_group.id))
    socket = assign(socket, weight_groups: weight_groups)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:weight_group, :pull_update], _updated_effective_date}, socket) do
    {:noreply, fetch_weight_groups(socket)}
  end

  @impl true
  def handle_info({[:weight_group, :updated], _updated_effective_date}, socket) do
    {:noreply, fetch_weight_groups(socket)}
  end

  @impl true
  def handle_info({[:effective_date, :updated], result}, socket) do
    %{effective_date: effective_date} = socket.assigns
    socket = cond do
      effective_date.id == result.id -> assign(socket, effective_date: result)
      true -> socket
    end
    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end
  # end handle info

  # handle event
  @impl true
  def handle_event("yard", %{"id" => id}, socket) do
    %{yards: yards} = socket.assigns
    yard = Enum.find(yards, &("#{&1.id}" == id))
    socket =
      assign(socket, yard: yard)
      |> fetch_weight_groups()
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, changeset: nil, modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_event("new_weight_group", _, socket) do
    %{yard: yard, effective_date: effective_date, weight_break: weight_break} = socket.assigns
    changeset =
      WeightGroups.new_weight_group(yard, effective_date, weight_break)
      |> WeightGroups.add_prices()
      |> WeightGroups.change_weight_group()
    socket = assign(socket, modal: :new_weight_group, changeset: changeset)
    {:noreply, socket}
  end

  @impl true
  def handle_event("duplicate", _, socket) do
    %{yard: yard, effective_date: effective_date} = socket.assigns
    WeightGroups.duplicate_to_yards(yard, effective_date)
    {:noreply, socket}
  end

  @impl true
  def handle_event("change_locked", _, socket) do
    %{effective_date: effective_date} = socket.assigns
    EffectiveDates.create_or_update_effective_date(effective_date, %{"locked" => !effective_date.locked})
    {:noreply, socket}
  end
  # end handle event
end
