defmodule PlugsApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      PlugsApp.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: PlugsApp.PubSub}
      # Start a worker by calling: PlugsApp.Worker.start_link(arg)
      # {PlugsApp.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: PlugsApp.Supervisor)
  end
end
