module Buyers
  module Levis
    class Mapper
      def self.build_excel_row(header, line_item)
        {
          "factory" => nil,
          "ship_under_po_ref" => header["ship_under_po_ref"] || nil,
          "article" => nil,
          "buyer" => header["buyer_company"] || nil,
          "buyer_division_dept" => nil,
          "currency" => header["currency"] || nil,
          "season" => header["season"] || nil,
          "country_of_origin" => "INDIA",
          "place_of_receipt_by_pre_carrier" => nil,
          "prod_capacity_booking_no" => nil,
          "order_initiation_date" => nil,
          "payment_terms" => "TT 90 DAYS",
          "buyer_po_num" => header["po_number"] || nil,
          "summary_buyer_order_ref" => header["po_number"] || nil,
          "market_buyer_order_ref" => header["ship_under_po_ref"] || nil,
          "destination_buyer_order_ref" => header["delivery_country"]&.upcase || nil,
          "delivery_buyer_order_ref" => header["po_number"] || nil,
          "buyer_order_date" => header["buyer_order_date"] || nil,
          "order_type" => "Confirmed",
          "mode_of_shipment" => "SEA",
          "buyer_delivery_date" => header["buyer_delivery_date"] || nil,
          "oc_delivery_date" => header["buyer_delivery_date"] || nil,
          "pcd_date" => nil,
          "original_gac_date" => nil,
          "gac_date" => nil,
          "raw_material_eta" => nil,
          "country_of_final_destination" => header["delivery_country"]&.upcase || nil,
          "final_destination" => header["delivery_country"]&.upcase || nil,
          "market" => "SOUTH-AMERICA",
          "buyer_style_ref" => header["ship_under_po_ref"] || nil,
          "packing_type" => nil,
          "packing_option_flat_pack" => nil,
          "color" => header["ffc_description"] || nil,
          "size" => line_item["size"] || nil,
          "total_qty" => line_item["quantity"] || nil,
          "price" => header["unit_price"] || nil,
          "units" => line_item["quantity"] || nil,
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
          "other_instruction" => nil
        }
      end
    end
  end
end
