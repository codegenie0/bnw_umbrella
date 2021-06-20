defmodule BnwDashboardWeb.BorrowingBase.Companies.SexCodes.SexCodesLive do
  use BnwDashboardWeb, :live_view

  alias BorrowingBase.SexCodes
  alias BnwDashboardWeb.BorrowingBase.Companies.SexCodes.SexCodeLive
  alias BnwDashboardWeb.BorrowingBase.Companies.CompaniesLive


  @impl true
  def mount(_params, %{"company" => company}, socket) do
    sex_codes =
      company
      |> SexCodes.list_sex_codes()
      |> Enum.concat([
        SexCodes.new_sex_code(%{gender: "steer"}),
        SexCodes.new_sex_code(%{gender: "heifer"}),
        SexCodes.new_sex_code(%{gender: "holstein"})
      ])
      |> Enum.map(&SexCodes.change_sex_code(&1))
      |> Enum.group_by(&(&1.data.gender))

    socket = assign(socket, sex_codes: sex_codes, company: company)
    if connected?(socket), do: SexCodes.subscribe()
    {:ok, socket}
  end

  # handle info
  @impl true
  def handle_info({[:sex_code, action], sex_code}, socket) do
    %{company: company} = socket.assigns
    cond do
      company == sex_code.company_id && Enum.member?([:updated, :deleted], action) ->
        {:noreply, push_redirect(socket, to: Routes.live_path(socket, CompaniesLive, %{sex_codes: true, company: company}), replace: true)}
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
