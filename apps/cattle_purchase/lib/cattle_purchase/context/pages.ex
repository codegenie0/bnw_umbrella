defmodule CattlePurchase.Pages do
  def list_pages() do
    [
      %{name: "Animal Ordering", url: "/cattle_purchase/animal_ordering"},
      %{name: "Commission Payee", url: "/cattle_purchase/commission_payee"},
      %{name: "Destination Groups", url: "/cattle_purchase/destination_groups"},
      %{name: "Page", url: "/cattle_purchase/page"},
      %{name: "Price Sheets", url: "/cattle_purchase/price_sheets"},
      %{name: "Purchase", url: "/cattle_purchase/purchases"},
      %{name: "Purchase Buyer", url: "/cattle_purchase/purchase_buyers"},
      %{name: "Purchase Flag", url: "/cattle_purchase/purchase_flags"},
      %{name: "Purchase Group", url: "/cattle_purchase/purchase_groups"},
      %{name: "Purchase Type", url: "/cattle_purchase/purchase_types"},
      %{name: "Purchase Type Filter", url: "/cattle_purchase/purchase_type_filters"},
      %{name: "Users", url: "/cattle_purchase/users"},
      %{name: "Weight Category", url: "/cattle_purchase/weight_categories"}
    ]
  end
end
