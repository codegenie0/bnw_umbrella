defmodule CihReportPlugs.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      CihReportPlugs.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: CihReportPlugs.PubSub}
      # Start a worker by calling: CihReportPlugs.Worker.start_link(arg)
      # {CihReportPlugs.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: CihReportPlugs.Supervisor)
  end
end
