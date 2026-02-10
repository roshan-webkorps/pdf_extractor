
module Buyers
  module Kontoor
    class Mapper
      def self.build_excel_row(header, line_item)
        {
          "factory" => "",
          "ship_under_po_ref" => header["po_number"] || "",
          "article" => "",
          "buyer" => "KONTOOR INTERNATIONAL SAGL- AIL",
          "buyer_division_dept" => "",
          "currency" => header["currency"] || "",
          "season" => header["season"] || "",
          "country_of_origin" => "INDIA",
          "place_of_receipt_by_pre_carrier" => "",
          "prod_capacity_booking_no" => "",
          "order_initiation_date" => header["po_issue_date"] || "",
          "payment_terms" => header["payment_terms"] || "",
          "buyer_po_num" => header["po_number"] || "",
          "summary_buyer_order_ref" => header["po_number"] || "",
          "market_buyer_order_ref" => header["po_number"] || "",
          "destination_buyer_order_ref" => header["po_number"] || "",
          "delivery_buyer_order_ref" => header["po_number"] || "",
          "buyer_order_date" => header["po_issue_date"] || "",
          "order_type" => "Confirmed",
          "mode_of_shipment" => header["shipment_mode"] || "",
          "buyer_delivery_date" => header["current_crd_date"] || "",
          "oc_delivery_date" => "",
          "pcd_date" => "",
          "original_gac_date" => "",
          "gac_date" => "",
          "raw_material_eta" => "",
          "country_of_final_destination" => header["shipping_destination"]&.upcase || "",
          "final_destination" => header["shipping_destination"]&.upcase || "",
          "market" => header["market"] || "",
          "buyer_style_ref" => header["style"] || "",
          "packing_type" => "",
          "packing_option_flat_pack" => "",
          "color" => line_item["color"] || "",
          "size" => line_item["size"] || "",
          "total_qty" => line_item["quantity"] || "",
          "price" => line_item["price"] || "",
          "units" => line_item["quantity"] || "",
          "delivery_terms" => header["delivery_terms"] || "",
          "zone" => "",
          "internal_lot_no" => "",
          "buyer_lot_no" => "",
          "delivery_ocid" => "",
          "fulfillment_type" => "Manufacture",
          "initial_pcd_date" => "",
          "first_buyer_delivery_date" => "",
          "packing_code" => "",
          "make_to_stock" => "",
          "split" => "",
          "other_instruction" => ""
        }
      end
    end
  end
end
