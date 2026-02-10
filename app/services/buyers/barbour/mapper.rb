
module Buyers
  module Barbour
    class Mapper
      def self.build_excel_row(header, line_item)
        {
          "factory" => "",
          "ship_under_po_ref" => header["order_no"] || "",
          "article" => "",
          "buyer" => "J Barbour and Sons Ltd",
          "buyer_division_dept" => "Mens",
          "currency" => "USD",
          "season" => "",
          "country_of_origin" => header["delivery_address"] || "",
          "place_of_receipt_by_pre_carrier" => "",
          "prod_capacity_booking_no" => "",
          "order_initiation_date" => "",
          "payment_terms" => "FOB",
          "buyer_po_num" => header["order_no"] || "",
          "summary_buyer_order_ref" => header["order_no"] || "",
          "market_buyer_order_ref" => header["order_no"] || "",
          "destination_buyer_order_ref" => header["delivery_address"] || "",
          "delivery_buyer_order_ref" => "",
          "buyer_order_date" => "",
          "order_type" => "Confirmed",
          "mode_of_shipment" => "Sea",
          "buyer_delivery_date" => "",
          "oc_delivery_date" => "",
          "pcd_date" => "",
          "original_gac_date" => "",
          "gac_date" => "",
          "raw_material_eta" => "",
          "country_of_final_destination" => header["delivery_address"] || "",
          "final_destination" => header["delivery_address"] || "",
          "market" => header["delivery_address"] || "",
          "buyer_style_ref" => line_item["item_number"] || "",
          "packing_type" => "",
          "packing_option_flat_pack" => "",
          "color" => line_item["colour"] || "",
          "size" => line_item["size"] || "",
          "total_qty" => line_item["quantity"] || "",
          "price" => line_item["purch_price"] || "",
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
