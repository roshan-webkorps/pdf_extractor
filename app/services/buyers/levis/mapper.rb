module Buyers
  module Levis
    class Mapper
      def self.build_excel_row(header, line_item)
        {
          "factory" => "",
          "ship_under_po_ref" => header["ship_under_po_ref"] || "",
          "article" => "",
          "buyer" => header["buyer_company"] || "",
          "buyer_division_dept" => "",
          "currency" => header["currency"] || "",
          "season" => header["season"] || "",
          "country_of_origin" => "INDIA",
          "place_of_receipt_by_pre_carrier" => "",
          "prod_capacity_booking_no" => "",
          "order_initiation_date" => "",
          "payment_terms" => "TT 90 DAYS",
          "buyer_po_num" => header["po_number"] || "",
          "summary_buyer_order_ref" => header["po_number"] || "",
          "market_buyer_order_ref" => header["ship_under_po_ref"] || "",
          "destination_buyer_order_ref" => header["delivery_country"]&.upcase || "",
          "delivery_buyer_order_ref" => header["po_number"] || "",
          "buyer_order_date" => header["buyer_order_date"] || "",
          "order_type" => "Confirmed",
          "mode_of_shipment" => "SEA",
          "buyer_delivery_date" => header["buyer_delivery_date"] || "",
          "oc_delivery_date" => header["buyer_delivery_date"] || "",
          "pcd_date" => "",
          "original_gac_date" => "",
          "gac_date" => "",
          "raw_material_eta" => "",
          "country_of_final_destination" => header["delivery_country"]&.upcase || "",
          "final_destination" => header["delivery_country"]&.upcase || "",
          "market" => "SOUTH-AMERICA",
          "buyer_style_ref" => header["ship_under_po_ref"] || "",
          "packing_type" => "",
          "packing_option_flat_pack" => "",
          "color" => header["ffc_description"] || "",
          "size" => line_item["size"] || "",
          "total_qty" => line_item["quantity"] || "",
          "price" => header["unit_price"] || "",
          "units" => line_item["quantity"] || "",
          "delivery_terms" => "FOB",
          "zone" => "",
          "internal_lot_no" => "",
          "buyer_lot_no" => "",
          "delivery_ocid" => "",
          "fulfillment_type" => "",
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
