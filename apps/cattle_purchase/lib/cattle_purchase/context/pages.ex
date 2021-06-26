defmodule CattlePurchase.Pages do
  def list_pages() do
    [
      %{name: "Page", url: "/cattle_purchase/page"},
      %{name: "Purchase Type", url: "/cattle_purchase/purchase_type"},
      %{name: "Purchase Flag", url: "/cattle_purchase/purchase_flag"}
    ]
  end
end
