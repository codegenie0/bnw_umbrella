defmodule BnwDashboardWeb.Router do
  import Phoenix.LiveDashboard.Router
  use BnwDashboardWeb, :router

  if Mix.env() == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {BnwDashboardWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :protected do
    plug BnwDashboardWeb.Authentication.Pipeline
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :it_admin_only do
    plug Guardian.Plug.EnsureAuthenticated
    plug BnwDashboardWeb.Plug.EnsureItAdmin
  end

  scope "/auth", BnwDashboardWeb do
    pipe_through :browser

    get "/reset_password", AuthController, :reset_password
    post "/reset_password", AuthController, :reset_password

    get "/request", AuthController, :request
    get "/:provider", AuthController, :request

    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback

    delete "/logout", AuthController, :delete
  end

  scope "/", BnwDashboardWeb do
    pipe_through [:browser, :protected, :ensure_auth]

    live "/", Home.HomeLive

    scope "/applications" do
      live "/", ComponentApplications.HomeLive
      live "/external", ComponentApplications.ExternalApplications.ExternalApplicationsLive
    end

    scope "/accounts" do
      live "/users", Accounts.Users.UsersLive
    end

    scope "/borrowing_base" do
      get "/csv_export", BorrowingBaseController, :csv_export

      live "/home", BorrowingBase.Home.HomeLive
      live "/companies", BorrowingBase.Companies.CompaniesLive
      live "/weight_breaks", BorrowingBase.WeightBreaks.WeightBreaksLive
    end

    scope "/customer_access" do
      live "/customers", CustomerAccess.Customers.CustomersLive
      live "/reports", CustomerAccess.Reports.ReportsLive
      live "/users", CustomerAccess.Users.UsersLive
    end

    scope "/ocb" do
      live "/plugs", OcbReportPlugs.Plugs.PlugsLive
      live "/users", OcbReportPlugs.Users.UsersLive
    end

    scope "/cih" do
      live "/plugs", CihReportPlugs.Plugs.PlugsLive
      live "/users", CihReportPlugs.Users.UsersLive
    end

    scope "/reimbursement" do
      live "/entries", Reimbursement.Update.UpdateLive
      live "/review", Reimbursement.Review.ReviewLive
      live "/rates", Reimbursement.Rates.RatesLive
      live "/users", Reimbursement.Users.UsersLive
      live "/reports", Reimbursement.Report.ReportsLive
      live "/help", Reimbursement.Help.HelpLive
    end

    scope "/plugs" do
      live "/projected_breakeven", PlugsApp.ProjectedBreakeven.ProjectedBreakevenLive
      live "/mpc_comparisons", PlugsApp.MpcComparison.MpcComparisonLive
      live "/packer_tyson_pricing", PlugsApp.PackerTysonPricing.PackerTysonPricingLive
      live "/packer_ab_pricing", PlugsApp.PackerAbPricing.PackerAbPricingLive
      live "/nbx_trucking", PlugsApp.NbxTrucking.NbxTruckingLive
      live "/fuel_usage", PlugsApp.FuelUsage.FuelUsageLive
      live "/profit_center_key", PlugsApp.ProfitCenterKey.ProfitCenterKeyLive
      live "/company_vehicles", PlugsApp.CompanyVehicleMile.CompanyVehicleMileLive
      live "/users", PlugsApp.Users.UsersLive
      live "/help", PlugsApp.Help.HelpLive
      live "/template", PlugsApp.Template.TemplateLive
    end

    scope "/cattle_purchase" do
      live "/animal_ordering", CattlePurchase.AnimalOrdering.AnimalOrderingLive
      live "/background", CattlePurchase.Background.BackgroundLive
      live "/commission_payee", CattlePurchase.CommissionPayee.CommissionPayeeLive
      live "/destination_groups", CattlePurchase.DestinationGroup.DestinationGroupLive
      live "/destination_groups/:id/destinations", CattlePurchase.Destination.DestinationLive
      live "/page", CattlePurchase.Page.PageLive
      live "/payees", CattlePurchase.Payees.PayeesLive
      live "/price_sheets", CattlePurchase.PriceSheet.PriceSheetLive
      live "/programs", CattlePurchase.Program.ProgramLive
      live "/purchases", CattlePurchase.Purchase.PurchaseLive
      live "/purchase_buyers", CattlePurchase.PurchaseBuyer.PurchaseBuyerLive
      live "/purchase_types", CattlePurchase.PurchaseType.PurchaseTypeLive
      live "/purchase_groups", CattlePurchase.PurchaseGroup.PurchaseGroupLive
      live "/purchase_flags", CattlePurchase.PurchaseFlag.PurchaseFlagLive
      live "/purchase_type_filters", CattlePurchase.PurchaseTypeFilter.PurchaseTypeFilterLive
      live "/purchase_receives", CattlePurchase.CattleReceive.CattleReceiveLive
      live "/purchase_shipments", CattlePurchase.PurchaseShipment.PurchaseShipmentLive
      live "/sellers", CattlePurchase.Seller.SellerLive
      live "/states", CattlePurchase.State.StateLive
      live "/treatments", CattlePurchase.Treatment.TreatmentLive
      live "/users", CattlePurchase.Users.UsersLive
      live "/weight_categories", CattlePurchase.WeightCategory.WeightCategoryLive
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", BnwDashboardWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  scope "/dashboard" do
    pipe_through [:browser, :protected, :it_admin_only]
    live_dashboard "/", metrics: BnwDashboardWeb.Telemetry
  end
end
