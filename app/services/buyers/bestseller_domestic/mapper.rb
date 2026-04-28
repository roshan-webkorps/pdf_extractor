
module Buyers
  module BestsellerDomestic
    class Mapper
      def self.build_excel_row(header, line_item)
        {
          "factory" => nil,
          "ship_under_po_ref" => header["po_number"] || nil,
          "article" => nil,
          "buyer" => header["communication_address"] || nil,
          "buyer_division_dept" => nil,
          "currency" => header["currency"] || nil,
          "season" => nil,
          "country_of_origin" => "INDIA",
          "place_of_receipt_by_pre_carrier" => nil,
          "prod_capacity_booking_no" => nil,
          "order_initiation_date" => header["po_date"] || nil,
          "payment_terms" => "FOB",
          "buyer_po_num" => header["po_number"] || nil,
          "summary_buyer_order_ref" => header["po_number"] || nil,
          "market_buyer_order_ref" => header["po_number"] || nil,
          "destination_buyer_order_ref" => "INDIA",
          "delivery_buyer_order_ref" => header["goods_ready_date"] || nil,
          "buyer_order_date" => header["po_date"] || nil,
          "order_type" => "Confirmed",
          "mode_of_shipment" => "Road",
          "buyer_delivery_date" => header["goods_ready_date"] || nil,
          "oc_delivery_date" => header["oc_delivery_date"] || nil,
          "pcd_date" => nil,
          "original_gac_date" => nil,
          "gac_date" => nil,
          "raw_material_eta" => nil,
          "country_of_final_destination" => "INDIA",
          "final_destination" => "BHIWANDI",
          "market" => "ASIA",
          "buyer_style_ref" => header["article_description"] || nil,
          "packing_type" => nil,
          "packing_option_flat_pack" => nil,
          "color" => line_item["colour"] || nil,
          "size" => line_item["size"] || nil,
          "total_qty" => line_item["quantity"] || nil,
          "price" => header["vcp_to_be"] || nil,
          "units" => "PCS",
          "delivery_terms" => "DAP",
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
