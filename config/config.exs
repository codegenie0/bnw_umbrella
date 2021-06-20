# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

# Configure Mix tasks and generators
config :cattle_purchase,
  ecto_repos: [CattlePurchase.Repo]

# Configure Mix tasks and generators
config :plugs_app,
  ecto_repos: [PlugsApp.Repo]

# Configure Mix tasks and generators
config :reimbursement,
  ecto_repos: [Reimbursement.Repo]

# Configure Mix tasks and generators
config :cih_report_plugs,
  ecto_repos: [CihReportPlugs.Repo]

# Configure Mix tasks and generators
config :ocb_report_plugs,
  ecto_repos: [OcbReportPlugs.Repo]

# Configure Mix tasks and generators
config :customer_access,
  ecto_repos: [CustomerAccess.Repo]

# Configure Mix tasks and generators
config :borrowing_base,
  ecto_repos: [BorrowingBase.Repo]

# Configure Mix tasks and generators
config :tentative_ship,
  ecto_repos: [TentativeShip.Repo]

# Configure Mix tasks and generators
config :accounts,
  ecto_repos: [Accounts.Repo]

# Configure Mix tasks and generators
config :component_applications,
  ecto_repos: [ComponentApplications.Repo]

# Configure Mix tasks and generators
config :bnw_dashboard,
  ecto_repos: [BnwDashboard.Repo]

config :bnw_dashboard_web,
  ecto_repos: [BnwDashboard.Repo],
  generators: [context_app: :bnw_dashboard]

# Configures the endpoint
config :bnw_dashboard_web, BnwDashboardWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "DoZJMIjDpoQX25KOS1A9ovQh4TBwk144mikoOrSM9IPcw1o4egMfdH8Yi5tbPirN",
  render_errors: [view: BnwDashboardWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: BnwDashboard.PubSub,
  live_view: [signing_salt: "Ur3NxPPY"]

# Configures ueberauth
config :ueberauth, Ueberauth,
  providers: [
    identity: {Ueberauth.Strategy.Identity, [
      callback_methods: ["POST"]
    ]},
    google: {Ueberauth.Strategy.Google, [default_scope: "email profile"]}
  ]

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET")

config :bnw_dashboard_web, Accounts.Authenticate,
  issuer: "bnw_dashboard",
  secret_key: System.get_env("GUARDIAN_SECRET_KEY")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
