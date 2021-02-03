# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :awesome,
  ecto_repos: [Awesome.Repo]

# Configures the endpoint
config :awesome, AwesomeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ObIT6MXUWJw3j5Vl2GiIbwhj6TBAt0WP6x87wZ3Ui69uwwP4gNa9EyBu9HQkodlm",
  render_errors: [view: AwesomeWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Awesome.PubSub,
  live_view: [signing_salt: "I85hE/P5"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
