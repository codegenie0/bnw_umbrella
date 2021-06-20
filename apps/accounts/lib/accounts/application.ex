defmodule Accounts.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Accounts.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Accounts.PubSub}
      # Start a worker by calling: Accounts.Worker.start_link(arg)
      # {Accounts.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Accounts.Supervisor)
  end
end
