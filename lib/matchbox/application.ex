defmodule Matchbox.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Matchbox.Repo,
      # Start the Telemetry supervisor
      MatchboxWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Matchbox.PubSub},
      # Start the Endpoint (http/https)
      MatchboxWeb.Endpoint,
      {Registry, keys: :unique, name: Matchbox.MatchRegistry},
      {DynamicSupervisor, strategy: :one_for_one, name: Matchbox.MatchSupervisor}
      # Start a worker by calling: Matchbox.Worker.start_link(arg)
      # {Matchbox.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Matchbox.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MatchboxWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
