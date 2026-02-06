
module Buyers
  module Asos
    class Mapper
      def self.build_excel_row(header, line_item)
        {
          "factory" => "TKL KNITS (INDIA) PRIVATE LIMITED",
          "ship_under_po_ref" => header["po_number"] || "",
          "article" => "",
          "buyer" => "ASOS",
          "buyer_division_dept" => "",
          "currency" => header["currency"] || "",
          "season" => "",
          "country_of_origin" => "INDIA",
          "place_of_receipt_by_pre_carrier" => line_item["final_destination"] || "",
          "prod_capacity_booking_no" => "",
          "order_initiation_date" => "",
          "payment_terms" => header["payment_terms"] || "",
          "buyer_po_num" => header["po_number"] || "",
          "summary_buyer_order_ref" => header["po_number"] || "",
          "market_buyer_order_ref" => header["po_number"] || "",
          "destination_buyer_order_ref" => header["po_number"] || "",
          "delivery_buyer_order_ref" => header["po_number"] || "",
          "buyer_order_date" => header["date_issued"] || "",
          "order_type" => "Confirmed",
          "mode_of_shipment" => header["delivery_method"] || "",
          "buyer_delivery_date" => header["handover_window_date"] || "",
          "oc_delivery_date" => header["oc_delivery_date"] || "",
          "pcd_date" => "",
          "original_gac_date" => "",
          "gac_date" => "",
          "raw_material_eta" => "",
          "country_of_final_destination" => header["first_destination"]&.upcase || "",
          "final_destination" => header["first_destination"]&.upcase || "",
          "market" => header["first_destination"]&.upcase || "",
          "buyer_style_ref" => line_item["supplier_ref"] || "",
          "packing_type" => "",
          "packing_option_flat_pack" => "",
          "color" => line_item["website_colour"] || "",
          "size" => line_item["brand_size"] || "",
          "total_qty" => line_item["quantity"] || "",
          "price" => line_item["unit_cost"] || "",
          "units" => header["po_total"] || "",
          "delivery_terms" => header["shipping_terms"] || "",
          "zone" => "",
          "internal_lot_no" => "",
          "buyer_lot_no" => "",
          "delivery_ocid" => "",
          "fulfillment_type" => "Manufacture",
          "initial_pcd_date" => "",
          "first_buyer_delivery_date" => "",
          "packing_code" => "",
          "make_to_stock" => "",
          "split" => ""
        }
      end
    end
  end
end
