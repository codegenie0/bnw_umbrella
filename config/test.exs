import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :cattle_purchase, CattlePurchase.Repo,
  username: "root",
  password: "sxkjad94",
  database: "bnw_dashboard_cattle_purchase_test",
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
  database: "bnw_dashboard_plugs_app_test",
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
  database: "bnw_dashboard_reimbursement_test",
  hostname: "bnw-dashboard-db",
  pool: Ecto.Adapters.SQL.Sandbox

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :cih_reports, CihReports.Repo,
  username: "root",
  password: "sxkjad94",
  database: "bnw_dashboard_cih_report_plugs_test",
  hostname: "bnw-dashboard-db",
  pool: Ecto.Adapters.SQL.Sandbox

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :ocb_report_plugs, OcbReportPlugs.Repo,
  username: "root",
  password: "sxkjad94",
  database: "bnw_dashboard_ocb_report_plugs_test",
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
  database: "bnw_dashboard_customer_access_test",
  hostname: "bnw-dashboard-db",
  pool: Ecto.Adapters.SQL.Sandbox

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :borrowing_base, BorrowingBase.Repo,
  username: "root",
  password: "sxkjad94",
  database: "bnw_dashboard_borrowing_base_test",
  hostname: "bnw-dashboard-db",
  pool: Ecto.Adapters.SQL.Sandbox

config :borrowing_base, BorrowingBase.Repo.Turnkey,
  username: System.get_env("AWS_DATABASES_USERNAME"),
  password: System.get_env("AWS_DATABASES_PASSWORD"),
  database: "turnkey",
  hostname: "System.get_env("AWS_DATABASES_URL")",
  pool: Ecto.Adapters.SQL.Sandbox

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :tentative_ship, TentativeShip.Repo,
  username: "root",
  password: "sxkjad94",
  database: "bnw_dashboard_tentative_ship_test",
  hostname: "bnw-dashboard-db",
  pool: Ecto.Adapters.SQL.Sandbox

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :accounts, Accounts.Repo,
  username: "root",
  password: "sxkjad94",
  database: "bnw_dashboard_accounts_test",
  hostname: "bnw-dashboard-db",
  pool: Ecto.Adapters.SQL.Sandbox

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :component_applications, ComponentApplications.Repo,
  username: "root",
  password: "sxkjad94",
  database: "bnw_dashboard_component_applications_test",
  hostname: "bnw-dashboard-db",
  pool: Ecto.Adapters.SQL.Sandbox

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :bnw_dashboard, BnwDashboard.Repo,
  username: "root",
  password: "sxkjad94",
  database: "bnw_dashboard_test",
  hostname: "bnw-dashboard-db",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :bnw_dashboard_web, BnwDashboardWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
