
module Buyers
  module Bestseller
    class Mapper
      def self.build_excel_row(header, line_item)
        {
          "factory" => nil,
          "ship_under_po_ref" => header["order_number"] || nil,
          "article" => nil,
          "buyer" => "Bestseller Exports-AIL",
          "buyer_division_dept" => "Mens",
          "currency" => header["price_per_item_currency"] || nil,
          "season" => header["collection"] || nil,
          "country_of_origin" => "INDIA",
          "place_of_receipt_by_pre_carrier" => nil,
          "prod_capacity_booking_no" => nil,
          "order_initiation_date" => header["1_print_date"] || nil,
          "payment_terms" => "FOB",
          "buyer_po_num" => header["order_number"] || nil,
          "summary_buyer_order_ref" => line_item["summary_buyer_order_ref"] || nil,
          "market_buyer_order_ref" => header["order_number"] || nil,
          "destination_buyer_order_ref" => header["destination"]&.upcase || nil,
          "delivery_buyer_order_ref" => header["delivery_buyer_order_ref"] || nil,
          "buyer_order_date" => header["1_print_date"] || nil,
          "order_type" => "Confirmed",
          "mode_of_shipment" => header["transportation"] || nil,
          "buyer_delivery_date" => header["buyer_delivery_date"] || nil,
          "oc_delivery_date" => header["oc_delivery_date"] || nil,
          "pcd_date" => nil,
          "original_gac_date" => nil,
          "gac_date" => nil,
          "raw_material_eta" => nil,
          "country_of_final_destination" => header["destination"]&.upcase || nil,
          "final_destination" => header["destination"]&.upcase || nil,
          "market" => header["market"] || nil,
          "buyer_style_ref" => header["style_information_name"] || nil,
          "packing_type" => nil,
          "packing_option_flat_pack" => nil,
          "color" => line_item["colour"] || nil,
          "size" => line_item["size"] || nil,
          "total_qty" => line_item["quantity"] || nil,
          "price" => header["price_per_item"] || nil,
          "units" => "PCS",
          "delivery_terms" => "FOB",
          "zone" => nil,
          "internal_lot_no" => nil,
          "buyer_lot_no" => nil,
          "delivery_ocid" => nil,
          "fulfillment_type" => "Manufacture",
          "initial_pcd_date" => nil,
          "first_buyer_delivery_date" => nil,
          "packing_code" => nil,
          "make_to_stock" => nil,
          "split" => nil,
          "other_instruction" => nil,
          "extra_production_pct" => nil,
          "upcharge" => nil
        }
      end
    end
  end
end
