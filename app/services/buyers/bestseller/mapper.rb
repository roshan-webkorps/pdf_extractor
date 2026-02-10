
module Buyers
  module Bestseller
    class Mapper
      def self.build_excel_row(header, line_item)
        {
          "factory" => "",
          "ship_under_po_ref" => header["order_number"] || "",
          "article" => "",
          "buyer" => "Bestseller Exports-AIL",
          "buyer_division_dept" => "Mens",
          "currency" => header["price_per_item_currency"] || "",
          "season" => header["collection"] || "",
          "country_of_origin" => "INDIA",
          "place_of_receipt_by_pre_carrier" => "",
          "prod_capacity_booking_no" => "",
          "order_initiation_date" => header["1_print_date"] || "",
          "payment_terms" => "FOB",
          "buyer_po_num" => header["order_number"] || "",
          "summary_buyer_order_ref" => line_item["summary_buyer_order_ref"] || "",
          "market_buyer_order_ref" => header["order_number"] || "",
          "destination_buyer_order_ref" => header["destination"]&.upcase || "",
          "delivery_buyer_order_ref" => header["delivery_buyer_order_ref"] || "",
          "buyer_order_date" => header["1_print_date"] || "",
          "order_type" => "Confirmed",
          "mode_of_shipment" => header["transportation"] || "",
          "buyer_delivery_date" => header["buyer_delivery_date"] || "",
          "oc_delivery_date" => header["oc_delivery_date"] || "",
          "pcd_date" => "",
          "original_gac_date" => "",
          "gac_date" => "",
          "raw_material_eta" => "",
          "country_of_final_destination" => header["destination"]&.upcase || "",
          "final_destination" => header["destination"]&.upcase || "",
          "market" => header["market"] || "",
          "buyer_style_ref" => header["style_information_name"] || "",
          "packing_type" => "",
          "packing_option_flat_pack" => "",
          "color" => line_item["colour"] || "",
          "size" => line_item["size"] || "",
          "total_qty" => line_item["quantity"] || "",
          "price" => header["price_per_item"] || "",
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
