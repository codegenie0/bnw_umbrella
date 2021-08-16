import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :cattle_purchase, CattlePurchase.Repo,
  username: "root",
  password: "sxkjad94",
  database: "cattle_purchase_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "bnw-dashboard-db",
  pool: Ecto.Adapters.SQL.Sandbox

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :plugs_app, PlugsApp.Repo,
  username: "root",
  password: "sxkjad94",
  database: "plugs_app_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "bnw-dashboard-db",
  pool: Ecto.Adapters.SQL.Sandbox

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :reimbursement, Reimbursement.Repo,
  username: "root",
  password: "sxkjad94",
  database: "reimbursement_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "bnw-dashboard-db",
  pool: Ecto.Adapters.SQL.Sandbox

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.

config :customer_access, CustomerAccess.Repo,
  username: "root",
  password: "sxkjad94",
  database: "customer_access_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "bnw-dashboard-db",
  pool: Ecto.Adapters.SQL.Sandbox

config :borrowing_base, BorrowingBase.Repo,
  username: "root",
  password: "sxkjad94",
  database: "borrowing_base_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "bnw-dashboard-db",
  pool: Ecto.Adapters.SQL.Sandbox

config :borrowing_base, BorrowingBase.Repo.Turnkey,
  username: System.get_env("AWS_DATABASES_USERNAME"),
  password: System.get_env("AWS_DATABASES_PASSWORD"),
  database: "turnkey",
  hostname: System.get_env("AWS_DATABASES_URL"),
  pool: Ecto.Adapters.SQL.Sandbox

config :tentative_ship, TentativeShip.Repo,
  username: "root",
  password: "sxkjad94",
  database: "tentative_ship_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "bnw-dashboard-db",
  pool: Ecto.Adapters.SQL.Sandbox

config :tentative_ship, TentativeShip.Repo.Turnkey,
  username: System.get_env("AWS_DATABASES_USERNAME"),
  password: System.get_env("AWS_DATABASES_PASSWORD"),
  database: "turnkey",
  hostname: System.get_env("AWS_DATABASES_URL"),
  pool: Ecto.Adapters.SQL.Sandbox

config :tentative_ship, TentativeShip.Repo.CattlePurchase,
  username: System.get_env("AWS_DATABASES_USERNAME"),
  password: System.get_env("AWS_DATABASES_PASSWORD"),
  database: "cattle_purchase",
  hostname: System.get_env("AWS_DATABASES_URL"),
  pool: Ecto.Adapters.SQL.Sandbox

config :tentative_ship, TentativeShip.Repo.Microbeef,
  username: System.get_env("AWS_DATABASES_USERNAME"),
  password: System.get_env("AWS_DATABASES_PASSWORD"),
  database: "microbeef_data",
  hostname: System.get_env("AWS_DATABASES_URL"),
  pool: Ecto.Adapters.SQL.Sandbox

config :accounts, Accounts.Repo,
  username: "root",
  password: "sxkjad94",
  database: "bnw_dashboard_accounts_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "bnw-dashboard-db",
  pool: Ecto.Adapters.SQL.Sandbox

config :component_applications, ComponentApplications.Repo,
  username: "root",
  password: "sxkjad94",
  database: "bnw_dashboard_component_applications_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "bnw-dashboard-db",
  pool: Ecto.Adapters.SQL.Sandbox

config :bnw_dashboard, BnwDashboard.Repo,
  username: "root",
  password: "sxkjad94",
  database: "bnw_dashboard_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "bnw-dashboard-db",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :bnw_dashboard_web, BnwDashboardWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :accounts, env: :test
config :bnw_dashboard, env: :test
config :bnw_dashboard_web, env: :test
config :borrowing_base, env: :test
config :component_applications, env: :test
config :customer_access, env: :test
config :tentative_ship, env: :test
config :ocb_report_plugs, env: :test
config :cih_report_plugs, env: :test
