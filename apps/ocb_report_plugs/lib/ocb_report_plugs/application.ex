defmodule OcbReportPlugs.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      OcbReportPlugs.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: OcbReportPlugs.PubSub}
      # Start a worker by calling: OcbReportPlugs.Worker.start_link(arg)
      # {OcbReportPlugs.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: OcbReportPlugs.Supervisor)
  end
end
