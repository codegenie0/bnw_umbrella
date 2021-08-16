import Config

# Configure your database
config :cattle_purchase, CattlePurchase.Repo,
  username: "root",
  password: "sxkjad94",
  database: "bnw_dashboard_cattle_purchase_dev",
  hostname: "bnw-dashboard-db",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# Configure your database
config :plugs_app, PlugsApp.Repo,
  username: "root",
  password: "sxkjad94",
  database: "bnw_dashboard_plugs_app_dev",
  hostname: "bnw-dashboard-db",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# Configure your database
config :reimbursement, Reimbursement.Repo,
  username: "root",
  password: "sxkjad94",
  database: "bnw_dashboard_reimbursement_dev",
  hostname: "bnw-dashboard-db",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# Configure your database
config :customer_access, CustomerAccess.Repo,
  username: "root",
  password: "sxkjad94",
  database: "bnw_dashboard_customer_access_dev",
  hostname: "bnw-dashboard-db",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :customer_access, CustomerAccess.Repo.Turnkey,
  username: System.get_env("AWS_DATABASES_USERNAME"),
  password: System.get_env("AWS_DATABASES_PASSWORD"),
  database: "turnkey",
  hostname: System.get_env("AWS_DATABASES_URL"),
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# Configure your database
config :borrowing_base, BorrowingBase.Repo,
  username: "root",
  password: "sxkjad94",
  database: "bnw_dashboard_borrowing_base_dev",
  hostname: "bnw-dashboard-db",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :borrowing_base, BorrowingBase.Repo.Turnkey,
  username: System.get_env("AWS_DATABASES_USERNAME"),
  password: System.get_env("AWS_DATABASES_PASSWORD"),
  database: "turnkey",
  hostname: System.get_env("AWS_DATABASES_URL"),
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :borrowing_base, BorrowingBase.Repo.InformationSchema,
  username: System.get_env("AWS_DATABASES_USERNAME"),
  password: System.get_env("AWS_DATABASES_PASSWORD"),
  database: "information_schema",
  hostname: System.get_env("AWS_DATABASES_URL"),
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# Configure your database
# Start Tentative Ship
config :tentative_ship, TentativeShip.Repo,
  username: "root",
  password: "sxkjad94",
  database: "bnw_dashboard_tentative_ship_dev",
  hostname: "bnw-dashboard-db",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# # for turnkey aws external connection
# config :tentative_ship, TentativeShip.Repo.Turnkey,
#   username: System.get_env("AWS_DATABASES_USERNAME"),
#   password: System.get_env("AWS_DATABASES_PASSWORD"),
#   database: "turnkey",
#   hostname: System.get_env("AWS_DATABASES_URL"),
#   show_sensitive_data_on_connection_error: true,
#   pool_size: 10

# for turnkey localhost connection
config :tentative_ship, TentativeShip.Repo.Turnkey,
  username: "root",
  password: "sxkjad94",
  database: "turnkey",
  hostname: "bnw-dashboard-db",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :tentative_ship, TentativeShip.Repo.CattlePurchase,
  username: System.get_env("AWS_DATABASES_USERNAME"),
  password: System.get_env("AWS_DATABASES_PASSWORD"),
  database: "cattle_purchase",
  hostname: System.get_env("AWS_DATABASES_URL"),
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :tentative_ship, TentativeShip.Repo.Microbeef,
  username: System.get_env("AWS_DATABASES_USERNAME"),
  password: System.get_env("AWS_DATABASES_PASSWORD"),
  database: "microbeef_data",
  hostname: System.get_env("AWS_DATABASES_URL"),
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
# End Tentative Ship

# Configure your database
config :accounts, Accounts.Repo,
  username: "root",
  password: "sxkjad94",
  database: "bnw_dashboard_accounts_dev",
  hostname: "bnw-dashboard-db",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# Configure your database
config :component_applications, ComponentApplications.Repo,
  username: "root",
  password: "sxkjad94",
  database: "bnw_dashboard_component_applications_dev",
  hostname: "bnw-dashboard-db",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# Configure your database
config :bnw_dashboard, BnwDashboard.Repo,
  username: "root",
  password: "sxkjad94",
  database: "bnw_dashboard_dev",
  hostname: "bnw-dashboard-db",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.
config :bnw_dashboard_web, BnwDashboardWeb.Endpoint,
  https: [
    port: 4000,
    cipher_suite: :strong,
    keyfile: "priv/cert/selfsigned_key.pem",
    certfile: "priv/cert/selfsigned.pem"
  ],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../apps/bnw_dashboard_web/assets", __DIR__)
    ]
  ]

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Note that this task requires Erlang/OTP 20 or later.
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :bnw_dashboard_web, BnwDashboardWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/bnw_dashboard_web/(live|views)/.*(ex)$",
      ~r"lib/bnw_dashboard_web/templates/.*(eex)$"
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

config :bnw_dashboard_web, BnwDashboardWeb.Mailer,
  adapter: Bamboo.LocalAdapter,
  open_email_in_browser_url: "http://localhost:4000/sent_emails"

config :accounts, env: :dev
config :bnw_dashboard, env: :dev
config :bnw_dashboard_web, env: :dev
config :borrowing_base, env: :dev
config :component_applications, env: :dev
config :customer_access, env: :dev
config :tentative_ship, env: :dev
config :reimbursement, env: :dev
config :plugs_app, env: :dev
