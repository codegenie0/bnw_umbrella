# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

config :cattle_purchase, CattlePurchase.Repo,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  username: System.get_env("AWS_DATABASES_USERNAME"),
  password: System.get_env("AWS_DATABASES_PASSWORD"),
  database: "bnw_dashboard_cattle_purchase",
  hostname: System.get_env("AWS_DATABASES_URL")

config :cattle_purchase, CattlePurchase.Repo.Turnkey,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  username: System.get_env("AWS_DATABASES_USERNAME"),
  password: System.get_env("AWS_DATABASES_PASSWORD"),
  database: "turnkey",
  hostname: System.get_env("AWS_DATABASES_URL")

config :plugs_app, PlugsApp.Repo,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  username: System.get_env("AWS_DATABASES_USERNAME"),
  password: System.get_env("AWS_DATABASES_PASSWORD"),
  database: "bnw_dashboard_plugs_app",
  hostname: System.get_env("AWS_DATABASES_URL")

config :reimbursement, Reimbursement.Repo,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  username: System.get_env("AWS_DATABASES_USERNAME"),
  password: System.get_env("AWS_DATABASES_PASSWORD"),
  database: "bnw_dashboard_reimbursement",
  hostname: System.get_env("AWS_DATABASES_URL")

config :ocb_report_plugs, OcbReportPlugs.Repo,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  username: System.get_env("AWS_DATABASES_USERNAME"),
  password: System.get_env("AWS_DATABASES_PASSWORD"),
  database: "bnw_dashboard_ocb_report_plugs",
  hostname: System.get_env("AWS_DATABASES_URL")

config :cih_report_plugs, CihReportPlugs.Repo,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  username: System.get_env("AWS_DATABASES_USERNAME"),
  password: System.get_env("AWS_DATABASES_PASSWORD"),
  database: "bnw_dashboard_cih_report_plugs",
  hostname: System.get_env("AWS_DATABASES_URL")

config :customer_access, CustomerAccess.Repo,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  username: System.get_env("AWS_DATABASES_USERNAME"),
  password: System.get_env("AWS_DATABASES_PASSWORD"),
  database: "bnw_dashboard_customer_access",
  hostname: System.get_env("AWS_DATABASES_URL")

config :customer_access, CustomerAccess.Repo.Turnkey,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  username: System.get_env("AWS_DATABASES_USERNAME"),
  password: System.get_env("AWS_DATABASES_PASSWORD"),
  database: "turnkey",
  hostname: System.get_env("AWS_DATABASES_URL")

config :borrowing_base, BorrowingBase.Repo,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  username: System.get_env("AWS_DATABASES_USERNAME"),
  password: System.get_env("AWS_DATABASES_PASSWORD"),
  database: "bnw_dashboard_borrowing_base",
  hostname: System.get_env("AWS_DATABASES_URL")

config :borrowing_base, BorrowingBase.Repo.Turnkey,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  username: System.get_env("AWS_DATABASES_USERNAME"),
  password: System.get_env("AWS_DATABASES_PASSWORD"),
  database: "turnkey",
  hostname: System.get_env("AWS_DATABASES_URL")

config :borrowing_base, BorrowingBase.Repo.InformationSchema,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  username: System.get_env("AWS_DATABASES_USERNAME"),
  password: System.get_env("AWS_DATABASES_PASSWORD"),
  database: "information_schema",
  hostname: System.get_env("AWS_DATABASES_URL")

config :tentative_ship, TentativeShip.Repo,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  username: System.get_env("AWS_DATABASES_USERNAME"),
  password: System.get_env("AWS_DATABASES_PASSWORD"),
  database: "bnw_dashboard_tentative_ship",
  hostname: System.get_env("AWS_DATABASES_URL")

config :accounts, Accounts.Repo,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  username: System.get_env("AWS_DATABASES_USERNAME"),
  password: System.get_env("AWS_DATABASES_PASSWORD"),
  database: "bnw_dashboard_accounts",
  hostname: System.get_env("AWS_DATABASES_URL")

config :component_applications, ComponentApplications.Repo,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  username: System.get_env("AWS_DATABASES_USERNAME"),
  password: System.get_env("AWS_DATABASES_PASSWORD"),
  database: "bnw_dashboard_component_applications",
  hostname: System.get_env("AWS_DATABASES_URL")

config :bnw_dashboard, BnwDashboard.Repo,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  username: System.get_env("AWS_DATABASES_USERNAME"),
  password: System.get_env("AWS_DATABASES_PASSWORD"),
  database: "bnw_dashboard",
  hostname: System.get_env("AWS_DATABASES_URL")

config :bnw_dashboard_web, BnwDashboardWeb.Endpoint,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  url: [host: System.get_env("HOSTNAME"), port: System.get_env("PORT") || 4000],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  server: true

config :bnw_dashboard_web, BnwDashboardWeb.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: System.get_env("SMTP_SERVER"),
  hostname: System.get_env("SMTP_HOSTNAME"),
  port: System.get_env("SMTP_PORT"),
  username: System.get_env("SMTP_USERNAME"),
  password: System.get_env("SMTP_PASSWORD"),
  tls: :always,
  allowed_tls_versions: [:tlsv1, :"tlsv1.1", :"tlsv1.2"],
  ssl: false,
  retries: 1,
  no_mx_lookups: false,
  auth: :always

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


# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :bnw_dashboard_web, BnwDashboardWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
