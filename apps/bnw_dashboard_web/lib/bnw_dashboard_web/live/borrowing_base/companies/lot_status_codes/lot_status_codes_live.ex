defmodule BnwDashboardWeb.BorrowingBase.Companies.LotStatusCodes.LotStatusCodesLive do
  use BnwDashboardWeb, :live_view

  alias BorrowingBase.LotStatusCodes
  alias BnwDashboardWeb.BorrowingBase.Companies.{
    CompaniesLive,
    LotStatusCodes.LotStatusCodeLive
  }

  @impl true
  def mount(_params, %{"company" => company}, socket) do
    lot_status_codes =
      company
      |> LotStatusCodes.list_lot_status_codes()
      |> Enum.concat([LotStatusCodes.new_lot_status_code()])
      |> Enum.map(&LotStatusCodes.change_lot_status_code(&1))

    socket = assign(socket, lot_status_codes: lot_status_codes, company: company)
    if connected?(socket), do: LotStatusCodes.subscribe()
    {:ok, socket}
  end

  # handle info
  @impl true
  def handle_info({[:lot_status_code, action], lot_status_code}, socket) do
    %{company: company} = socket.assigns
    cond do
      company == lot_status_code.company_id && Enum.member?([:updated, :deleted], action) ->
        {:noreply, push_redirect(socket, to: Routes.live_path(socket, CompaniesLive, %{lot_status_codes: true, company: company}), replace: true)}
      true ->
        {:noreply, socket}
    end
  end
  # end hadle info

  # handle event
  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, changeset: nil, modal: nil)
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, CompaniesLive), replace: true)}
  end
  # end handle event
end
