defmodule BnwDashboardWeb.PlugsApp.Help.HelpLive do

  use BnwDashboardWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    socket =
      assign_defaults(session, socket)
      |> assign(page_title: "BNW Dashboard · Plugs Help",
                app: "Plugs",
                draft_number: "Draft 1 15/Jun/2021",
                modal: nil)
    {:ok, socket}
  end

end
