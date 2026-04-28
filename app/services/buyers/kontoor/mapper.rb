
module Buyers
  module Kontoor
    class Mapper
      def self.build_excel_row(header, line_item)
        {
          "factory" => nil,
          "ship_under_po_ref" => header["po_number"] || nil,
          "article" => nil,
          "buyer" => "KONTOOR INTERNATIONAL SAGL- AIL",
          "buyer_division_dept" => nil,
          "currency" => header["currency"] || nil,
          "season" => header["season"] || nil,
          "country_of_origin" => "INDIA",
          "place_of_receipt_by_pre_carrier" => nil,
          "prod_capacity_booking_no" => nil,
          "order_initiation_date" => header["po_issue_date"] || nil,
          "payment_terms" => header["payment_terms"] || nil,
          "buyer_po_num" => header["po_number"] || nil,
          "summary_buyer_order_ref" => header["po_number"] || nil,
          "market_buyer_order_ref" => header["po_number"] || nil,
          "destination_buyer_order_ref" => header["po_number"] || nil,
          "delivery_buyer_order_ref" => header["po_number"] || nil,
          "buyer_order_date" => header["po_issue_date"] || nil,
          "order_type" => "Confirmed",
          "mode_of_shipment" => header["shipment_mode"] || nil,
          "buyer_delivery_date" => header["current_crd_date"] || nil,
          "oc_delivery_date" => nil,
          "pcd_date" => nil,
          "original_gac_date" => nil,
          "gac_date" => nil,
          "raw_material_eta" => nil,
          "country_of_final_destination" => header["shipping_destination"]&.upcase || nil,
          "final_destination" => header["shipping_destination"]&.upcase || nil,
          "market" => header["market"] || nil,
          "buyer_style_ref" => header["style"] || nil,
          "packing_type" => nil,
          "packing_option_flat_pack" => nil,
          "color" => line_item["color"] || nil,
          "size" => line_item["size"] || nil,
          "total_qty" => line_item["quantity"] || nil,
          "price" => line_item["price"] || nil,
          "units" => line_item["quantity"] || nil,
          "delivery_terms" => header["delivery_terms"] || nil,
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
