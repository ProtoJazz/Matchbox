# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :matchbox,
  ecto_repos: [Matchbox.Repo]

# Configures the endpoint
config :matchbox, MatchboxWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "O6U4BiWu032/qOFiQ1vXLt17Hix7XQKzr1a4fhHqVfqWWqJEcC0AQZqZzjwWNcfY",
  render_errors: [view: MatchboxWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Matchbox.PubSub,
  live_view: [signing_salt: "qIK37k3n"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

config :matchbox, [
  riot_key: System.get_env("RIOT_KEY"),
  provider_id: System.get_env("PROVIDER_ID")
]
