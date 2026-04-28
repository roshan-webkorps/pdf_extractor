
module Buyers
  module Barbour
    class Mapper
      def self.build_excel_row(header, line_item)
        {
          "factory" => nil,
          "ship_under_po_ref" => header["order_no"] || nil,
          "article" => nil,
          "buyer" => "J Barbour and Sons Ltd",
          "buyer_division_dept" => "Mens",
          "currency" => "USD",
          "season" => nil,
          "country_of_origin" => header["delivery_address"] || nil,
          "place_of_receipt_by_pre_carrier" => nil,
          "prod_capacity_booking_no" => nil,
          "order_initiation_date" => nil,
          "payment_terms" => "FOB",
          "buyer_po_num" => header["order_no"] || nil,
          "summary_buyer_order_ref" => header["order_no"] || nil,
          "market_buyer_order_ref" => header["order_no"] || nil,
          "destination_buyer_order_ref" => header["delivery_address"] || nil,
          "delivery_buyer_order_ref" => nil,
          "buyer_order_date" => nil,
          "order_type" => "Confirmed",
          "mode_of_shipment" => "Sea",
          "buyer_delivery_date" => nil,
          "oc_delivery_date" => nil,
          "pcd_date" => nil,
          "original_gac_date" => nil,
          "gac_date" => nil,
          "raw_material_eta" => nil,
          "country_of_final_destination" => header["delivery_address"] || nil,
          "final_destination" => header["delivery_address"] || nil,
          "market" => header["delivery_address"] || nil,
          "buyer_style_ref" => line_item["item_number"] || nil,
          "packing_type" => nil,
          "packing_option_flat_pack" => nil,
          "color" => line_item["colour"] || nil,
          "size" => line_item["size"] || nil,
          "total_qty" => line_item["quantity"] || nil,
          "price" => line_item["purch_price"] || nil,
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
