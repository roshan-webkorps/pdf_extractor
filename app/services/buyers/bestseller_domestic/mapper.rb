
module Buyers
  module BestsellerDomestic
    class Mapper
      def self.build_excel_row(header, line_item)
        {
          "factory" => "",
          "ship_under_po_ref" => header["po_number"] || "",
          "article" => "",
          "buyer" => header["communication_address"] || "",
          "buyer_division_dept" => "",
          "currency" => header["currency"] || "",
          "season" => "",
          "country_of_origin" => "INDIA",
          "place_of_receipt_by_pre_carrier" => "",
          "prod_capacity_booking_no" => "",
          "order_initiation_date" => header["po_date"] || "",
          "payment_terms" => "FOB",
          "buyer_po_num" => header["po_number"] || "",
          "summary_buyer_order_ref" => header["po_number"] || "",
          "market_buyer_order_ref" => header["po_number"] || "",
          "destination_buyer_order_ref" => "INDIA",
          "delivery_buyer_order_ref" => header["goods_ready_date"] || "",
          "buyer_order_date" => header["po_date"] || "",
          "order_type" => "Confirmed",
          "mode_of_shipment" => "Road",
          "buyer_delivery_date" => header["goods_ready_date"] || "",
          "oc_delivery_date" => header["oc_delivery_date"] || "",
          "pcd_date" => "",
          "original_gac_date" => "",
          "gac_date" => "",
          "raw_material_eta" => "",
          "country_of_final_destination" => "INDIA",
          "final_destination" => "BHIWANDI",
          "market" => "ASIA",
          "buyer_style_ref" => header["article_description"] || "",
          "packing_type" => "",
          "packing_option_flat_pack" => "",
          "color" => line_item["colour"] || "",
          "size" => line_item["size"] || "",
          "total_qty" => line_item["quantity"] || "",
          "price" => header["vcp_to_be"] || "",
          "units" => "PCS",
          "delivery_terms" => "DAP",
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
