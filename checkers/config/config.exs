# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :checkers,
  ecto_repos: [Checkers.Repo]

# Configures the endpoint
config :checkers, CheckersWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "gOpLWa7e7g79JA23QUB4Rrb4QBElheaLbVI50jWzZRN+L4lqHR5HvOnth8u9E6Cu",
  render_errors: [view: CheckersWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Checkers.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
