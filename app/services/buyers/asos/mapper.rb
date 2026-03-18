
module Buyers
  module Asos
    class Mapper
      def self.build_excel_row(header, line_item)
        {
          "factory" => "TKL KNITS (INDIA) PRIVATE LIMITED",
          "ship_under_po_ref" => header["po_number"] || nil,
          "article" => nil,
          "buyer" => "ASOS",
          "buyer_division_dept" => nil,
          "currency" => header["currency"] || nil,
          "season" => nil,
          "country_of_origin" => "INDIA",
          "place_of_receipt_by_pre_carrier" => line_item["final_destination"] || nil,
          "prod_capacity_booking_no" => nil,
          "order_initiation_date" => nil,
          "payment_terms" => header["payment_terms"] || nil,
          "buyer_po_num" => header["po_number"] || nil,
          "summary_buyer_order_ref" => header["po_number"] || nil,
          "market_buyer_order_ref" => header["po_number"] || nil,
          "destination_buyer_order_ref" => header["po_number"] || nil,
          "delivery_buyer_order_ref" => header["po_number"] || nil,
          "buyer_order_date" => header["date_issued"] || nil,
          "order_type" => "Confirmed",
          "mode_of_shipment" => header["delivery_method"] || nil,
          "buyer_delivery_date" => header["handover_window_date"] || nil,
          "oc_delivery_date" => header["oc_delivery_date"] || nil,
          "pcd_date" => nil,
          "original_gac_date" => nil,
          "gac_date" => nil,
          "raw_material_eta" => nil,
          "country_of_final_destination" => header["first_destination"]&.upcase || nil,
          "final_destination" => header["first_destination"]&.upcase || nil,
          "market" => header["first_destination"]&.upcase || nil,
          "buyer_style_ref" => line_item["supplier_ref"] || nil,
          "packing_type" => nil,
          "packing_option_flat_pack" => nil,
          "color" => line_item["website_colour"] || nil,
          "size" => line_item["brand_size"] || nil,
          "total_qty" => header["po_total"] || nil,
          "price" => line_item["unit_cost"] || nil,
          "units" => line_item["quantity"] || nil,
          "delivery_terms" => header["shipping_terms"] || nil,
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
