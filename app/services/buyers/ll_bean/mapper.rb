
module Buyers
  module LlBean
    class Mapper
      def self.build_excel_row(header, line_item)
        {
          "factory" => nil,
          "ship_under_po_ref" => header["po"] || nil,
          "article" => nil,
          "buyer" => "L.L.Bean",
          "buyer_division_dept" => "Mens",
          "currency" => "USD",
          "season" => header["season_year"] || nil,
          "country_of_origin" => header["delivery_address"] || nil,
          "place_of_receipt_by_pre_carrier" => nil,
          "prod_capacity_booking_no" => nil,
          "order_initiation_date" => nil,
          "payment_terms" => "FCA",
          "buyer_po_num" => header["po"] || nil,
          "summary_buyer_order_ref" => header["item_id"] || nil,
          "market_buyer_order_ref" => nil,
          "destination_buyer_order_ref" => header["delivery_address"] || nil,
          "delivery_buyer_order_ref" =>  header["po"] || nil,
          "buyer_order_date" => nil,
          "order_type" => "Confirmed",
          "mode_of_shipment" => line_item["ship_mode"] || nil,
          "buyer_delivery_date" => header["buyer_delivery_date"] || nil,
          "oc_delivery_date" => header["oc_delivery_date"] || nil,
          "pcd_date" => nil,
          "original_gac_date" => nil,
          "gac_date" => nil,
          "raw_material_eta" => nil,
          "country_of_final_destination" => header["delivery_address"] || nil,
          "final_destination" => header["delivery_address"] || nil,
          "market" => header["delivery_address"] || nil,
          "buyer_style_ref" => header["item_id_description"] || nil,
          "packing_type" => nil,
          "packing_option_flat_pack" => nil,
          "color" => line_item["colour"] || nil,
          "size" => line_item["size"] || nil,
          "total_qty" => line_item["quantity"] || nil,
          "price" => line_item["purchase_price"] || nil,
          "units" => "PCS",
          "delivery_terms" => "FCA",
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
