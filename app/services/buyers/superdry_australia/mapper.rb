module Buyers
  module SuperdryAustralia
    class Mapper
      def self.build_excel_row(header, line_item)
        {
          "factory" => "",
          "ship_under_po_ref" => header["purchase_order_number"] || "",
          "article" => "",
          "buyer" => "Superdry Australia",
          "buyer_division_dept" => "",
          "currency" => header["currency"] || "",
          "season" => "",
          "country_of_origin" => "India",
          "place_of_receipt_by_pre_carrier" => "",
          "prod_capacity_booking_no" => "",
          "order_initiation_date" => "",
          "payment_terms" => "TT60",
          "buyer_po_num" => header["purchase_order_number"] || "",
          "summary_buyer_order_ref" => header["purchase_order_number"] || "",
          "market_buyer_order_ref" => "",
          "destination_buyer_order_ref" => "Australia",
          "delivery_buyer_order_ref" => header["purchase_order_number"] || "",
          "buyer_order_date" => header["po_create_date"] || "",
          "order_type" => "Confirmed",
          "mode_of_shipment" => "Sea",
          "buyer_delivery_date" => line_item["buyer_delivery_date"] || "",
          "oc_delivery_date" => line_item["oc_delivery_date"] || "",
          "pcd_date" => "",
          "original_gac_date" => "",
          "gac_date" => "",
          "raw_material_eta" => "",
          "country_of_final_destination" => "Australia",
          "final_destination" => "Australia",
          "market" => "Australia",
          "buyer_style_ref" => line_item["style_no"] || "",
          "packing_type" => "",
          "packing_option_flat_pack" => "",
          "color" => line_item["colour"] || "",
          "size" => line_item["size"] || "",
          "total_qty" => line_item["quantity"] || "",
          "price" => line_item["price"] || "",
          "units" => "PCS",
          "delivery_terms" => "FOB",
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
