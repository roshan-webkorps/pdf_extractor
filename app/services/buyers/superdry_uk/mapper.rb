module Buyers
  module SuperdryUk
    class Mapper
      def self.build_excel_row(header, line_item)
        {
          "factory" => "",
          "ship_under_po_ref" => header["po_no"] || "",
          "article" => "",
          "buyer" => "Superdry",
          "buyer_division_dept" => "",
          "currency" => header["supplier_currency"] || "",
          "season" => header["season_year"] || "",
          "country_of_origin" => "India",
          "place_of_receipt_by_pre_carrier" => "",
          "prod_capacity_booking_no" => "",
          "order_initiation_date" => "",
          "payment_terms" => "TT60",
          "buyer_po_num" => header["po_no"] || "",
          "summary_buyer_order_ref" => header["po_no"] || "",
          "market_buyer_order_ref" => "",
          "destination_buyer_order_ref" => "UK",
          "delivery_buyer_order_ref" => header["po_no"] || "",
          "buyer_order_date" => header["po_date"] || "",
          "order_type" => "Confirmed",
          "mode_of_shipment" => "Sea",
          "buyer_delivery_date" => line_item["buyer_delivery_date"] || "",
          "oc_delivery_date" => line_item["oc_delivery_date"] || "",
          "pcd_date" => "",
          "original_gac_date" => "",
          "gac_date" => "",
          "raw_material_eta" => "",
          "country_of_final_destination" => "UK",
          "final_destination" => "UK",
          "market" => "Europe",
          "buyer_style_ref" => line_item["style"] || "",
          "packing_type" => "",
          "packing_option_flat_pack" => "",
          "color" => line_item["colour"] || "",
          "size" => line_item["size"] || "",
          "total_qty" => line_item["quantity"] || "",
          "price" => line_item["cost"] || "",
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
          "split" => ""
        }
      end
    end
  end
end
