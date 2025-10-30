module Buyers
  module PvhTommy
    class Mapper
      def self.build_excel_row(header, line_item)
        {
          "factory" => "",
          "ship_under_po_ref" => header["po_number"] || "",
          "article" => "",
          "buyer" => "TOMMY HILFIGER EUROPE BV",
          "buyer_division_dept" => header["product_division"] || "",
          "currency" => header["currency"] || "",
          "season" => "",
          "country_of_origin" => "INDIA",
          "place_of_receipt_by_pre_carrier" => header["consignee"]&.upcase || "",
          "prod_capacity_booking_no" => "",
          "order_initiation_date" => "",
          "payment_terms" => header["pay_terms"] || "",
          "buyer_po_num" => header["po_number"] || "",
          "summary_buyer_order_ref" => "",
          "market_buyer_order_ref" => "",
          "destination_buyer_order_ref" => header["po_number"] || "",
          "delivery_buyer_order_ref" => "",
          "buyer_order_date" => header["buyer_order_date"] || "",
          "order_type" => "Confirmed",
          "mode_of_shipment" => header["ship_mode"] || "",
          "buyer_delivery_date" => header["buyer_delivery_date"] || "",
          "oc_delivery_date" => header["buyer_delivery_date"] || "",
          "pcd_date" => "",
          "original_gac_date" => "",
          "gac_date" => "",
          "raw_material_eta" => "",
          "country_of_final_destination" => header["consignee"]&.upcase || "",
          "final_destination" => header["consignee"]&.upcase || "",
          "market" => header["buyer"]&.upcase || "",
          "buyer_style_ref" => line_item["style"] || "",
          "packing_type" => header["pack_method"] || "",
          "packing_option_flat_pack" => "",
          "color" => line_item["ffc_description"] || "",
          "size" => line_item["size"] || "",
          "total_qty" => line_item["quantity"] || "",
          "price" => line_item["cost"] || "",
          "units" => line_item["total_units"] || "",
          "delivery_terms" => header["inco_terms"] || "",
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
