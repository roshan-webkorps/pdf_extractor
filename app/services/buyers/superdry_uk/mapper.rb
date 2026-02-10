module Buyers
  module SuperdryUk
    class Mapper
      def self.build_excel_row(header, line_item)
        {
          "factory" => nil,
          "ship_under_po_ref" => header["po_no"] || nil,
          "article" => nil,
          "buyer" => "Superdry",
          "buyer_division_dept" => nil,
          "currency" => header["supplier_currency"] || nil,
          "season" => header["season_year"] || nil,
          "country_of_origin" => "India",
          "place_of_receipt_by_pre_carrier" => nil,
          "prod_capacity_booking_no" => nil,
          "order_initiation_date" => nil,
          "payment_terms" => "TT60",
          "buyer_po_num" => header["po_no"] || nil,
          "summary_buyer_order_ref" => header["po_no"] || nil,
          "market_buyer_order_ref" => nil,
          "destination_buyer_order_ref" => "UK",
          "delivery_buyer_order_ref" => header["po_no"] || nil,
          "buyer_order_date" => header["po_date"] || nil,
          "order_type" => "Confirmed",
          "mode_of_shipment" => "Sea",
          "buyer_delivery_date" => line_item["buyer_delivery_date"] || nil,
          "oc_delivery_date" => line_item["oc_delivery_date"] || nil,
          "pcd_date" => nil,
          "original_gac_date" => nil,
          "gac_date" => nil,
          "raw_material_eta" => nil,
          "country_of_final_destination" => "UK",
          "final_destination" => "UK",
          "market" => "Europe",
          "buyer_style_ref" => line_item["style"] || nil,
          "packing_type" => nil,
          "packing_option_flat_pack" => nil,
          "color" => line_item["colour"] || nil,
          "size" => line_item["size"] || nil,
          "total_qty" => line_item["quantity"] || nil,
          "price" => line_item["cost"] || nil,
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
          "other_instruction" => nil
        }
      end
    end
  end
end
