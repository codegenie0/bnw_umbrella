defmodule CustomerAccess.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      CustomerAccess.Repo,
      CustomerAccess.Repo.Turnkey,
      # Start the PubSub system
      {Phoenix.PubSub, name: CustomerAccess.PubSub},
      # Start a worker by calling: CustomerAccess.Worker.start_link(arg)
      # {CustomerAccess.Worker, arg}
      {CustomerAccess.DataPipeline, name: CustomerAccess.DataPipeline}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: CustomerAccess.Supervisor)
  end
end
