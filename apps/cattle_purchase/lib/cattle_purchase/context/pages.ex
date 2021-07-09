defmodule CattlePurchase.Pages do
  def list_pages() do
    [
      %{name: "Animal Ordering", url: "/cattle_purchase/animal_ordering"},
      %{name: "Destination Groups", url: "/cattle_purchase/destination_groups"},
      %{name: "Page", url: "/cattle_purchase/page"},
      %{name: "Purchase Buyer", url: "/cattle_purchase/purchase_buyers"},
      %{name: "Purchase Type", url: "/cattle_purchase/purchase_types"},
      %{name: "Purchase Group", url: "/cattle_purchase/purchase_groups"},
      %{name: "Purchase Flag", url: "/cattle_purchase/purchase_flags"},
      %{name: "Weight Category", url: "/cattle_purchase/weight_categories"},
      %{name: "Users", url: "/cattle_purchase/users"}

    ]
  end
end
