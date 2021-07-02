defmodule CattlePurchase.Pages do
  def list_pages() do
    [
      %{name: "Animal Ordering", url: "/cattle_purchase/animal_ordering"},
      %{name: "Page", url: "/cattle_purchase/page"},
      %{name: "Purchase Type", url: "/cattle_purchase/purchase_types"},
      %{name: "Purchase Group", url: "/cattle_purchase/purchase_groups"},
      %{name: "Purchase Flag", url: "/cattle_purchase/purchase_flags"},
      %{name: "Users", url: "/cattle_purchase/users"}

    ]
  end
end
