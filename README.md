# BnwDashboard.Umbrella

## Run App Migrations in this order
  * bnw_dashboard
  * accounts
  * component_applications
  * bnw_dashboard_web
  * borrowing_base
  * customer_access
  * tentative_ship
  * ocb_report_plugs
  * cih_report_plugs
  * reimbursement
  * $any_future_apps

## App migration command
  * dc run app mix cmd --app $app_name mix ecto.create
  * dc run app mix cmd --app $app_name mix ecto.migrate
