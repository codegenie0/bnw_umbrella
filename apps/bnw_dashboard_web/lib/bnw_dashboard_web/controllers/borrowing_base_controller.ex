defmodule BnwDashboardWeb.BorrowingBaseController do
  use BnwDashboardWeb, :controller

  alias BorrowingBase.LotAdjustments

  def csv_export(conn, params) do
    %{
      "effective_date_id" => effective_date_id,
      "search" => search,
      "search_col" => search_col,
      "sort_by" => sort_by,
      "sort_order" => sort_order,
      "yard_id" => yard_id
    } = params

    conn =
      conn
      |> put_resp_content_type("text/csv")
      |> put_resp_header("content-disposition", ~s[attachment; filename="borrowing_base_#{DateTime.utc_now |> DateTime.to_iso8601(:basic) |> String.replace(".", "")}.csv"])
      |> send_chunked(:ok)

    LotAdjustments.list_lot_adjustments_with_stream(
      effective_date_id,
      yard_id,
      sort_by,
      sort_order,
      search_col,
      search,
      fn stream ->
        for result <- stream do
          csv_rows = NimbleCSV.RFC4180.dump_to_iodata([result])
          chunk(conn, csv_rows)
        end
      end)

    conn
  end
end
