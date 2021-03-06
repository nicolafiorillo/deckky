# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :deckky, DeckkyWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "uacZ+9PPdtEz3HaUmwhG3cXuBW4s3e0oy/W72dvgqsSadcS7RH2ul1PwWD7ACiR2",
  render_errors: [view: DeckkyWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Deckky.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :injex,
  persistence: Deckky.Persistence.Disk

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
