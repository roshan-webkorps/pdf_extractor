
module Buyers
  module LlBean
    class Mapper
      def self.build_excel_row(header, line_item)
        {
          "factory" => "",
          "ship_under_po_ref" => header["po"] || "",
          "article" => "",
          "buyer" => "L.L.Bean",
          "buyer_division_dept" => "Mens",
          "currency" => "USD",
          "season" => header["season_year"] || "",
          "country_of_origin" => header["delivery_address"] || "",
          "place_of_receipt_by_pre_carrier" => "",
          "prod_capacity_booking_no" => "",
          "order_initiation_date" => "",
          "payment_terms" => "FCA",
          "buyer_po_num" => header["po"] || "",
          "summary_buyer_order_ref" => header["item_id"] || "",
          "market_buyer_order_ref" => "",
          "destination_buyer_order_ref" => header["delivery_address"] || "",
          "delivery_buyer_order_ref" =>  header["po"] || "",
          "buyer_order_date" => "",
          "order_type" => "Confirmed",
          "mode_of_shipment" => line_item["ship_mode"] || "",
          "buyer_delivery_date" => header["buyer_delivery_date"] || "",
          "oc_delivery_date" => header["oc_delivery_date"] || "",
          "pcd_date" => "",
          "original_gac_date" => "",
          "gac_date" => "",
          "raw_material_eta" => "",
          "country_of_final_destination" => header["delivery_address"] || "",
          "final_destination" => header["delivery_address"] || "",
          "market" => header["delivery_address"] || "",
          "buyer_style_ref" => header["item_id_description"] || "",
          "packing_type" => "",
          "packing_option_flat_pack" => "",
          "color" => line_item["colour"] || "",
          "size" => line_item["size"] || "",
          "total_qty" => line_item["quantity"] || "",
          "price" => line_item["purchase_price"] || "",
          "units" => "PCS",
          "delivery_terms" => "FCA",
          "zone" => "",
          "internal_lot_no" => "",
          "buyer_lot_no" => "",
          "delivery_ocid" => "",
          "fulfillment_type" => "",
          "initial_pcd_date" => "",
          "first_buyer_delivery_date" => "",
          "packing_code" => "",
          "make_to_stock" => "",
          "split" => ""
        }
      end
    end
  end
end
