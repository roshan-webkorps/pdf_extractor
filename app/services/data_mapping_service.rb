class DataMappingService
  def initialize(parsed_pos)
    @parsed_pos = parsed_pos
  end

  def map_to_excel_format
    excel_rows = []

    @parsed_pos.each do |po|
      header = po[:header_data]
      line_items = po[:line_items]

      if line_items.empty?
        excel_rows << map_single_row(header, {})
      else
        line_items.each do |item|
          excel_rows << map_single_row(header, item)
        end
      end
    end

    excel_rows
  end

  private

  def map_single_row(header, line_item)
    {
      factory: "",
      ship_under_po_ref: line_item[:material_code] || header[:generic_material] || header[:material] || header[:product] || "",
      article: "",
      buyer: extract_buyer_name(header[:invoice_to]),
      buyer_division_dept: "",
      currency: header[:currency] || "USD",
      season: header[:season] || header[:season_code] || "",
      country_of_origin: "India",
      place_of_receipt_by_pre_carrier: "",
      prod_capacity_booking_no: "",
      order_initiation_date: "",
      payment_terms: "TT 90 DAYS",
      buyer_po_num: header[:purchase_order_number] || "",
      summary_buyer_order_ref: header[:purchase_order_number] || "",
      market_buyer_order_ref: line_item[:material_code] || header[:generic_material] || header[:material] || header[:product] || "",
      destination_buyer_order_ref: extract_country(header[:delivery_address]),
      delivery_buyer_order_ref: header[:purchase_order_number] || "",
      buyer_order_date: header[:doc_date] || "",
      order_type: "Confirmed",
      mode_of_shipment: "SEA",
      buyer_delivery_date: header[:planned_hod] || header[:original_ex_fac_date] || header[:original_ex_fac_date] || "",
      oc_delivery_date: header[:planned_hod] || header[:original_ex_fac_date] || header[:original_ex_fac_date] || "",
      pcd_date: "",
      original_gac_date: "",
      gac_date: "",
      raw_material_eta: "",
      country_of_final_destination: extract_country(header[:delivery_address]),
      final_destination: extract_country(header[:delivery_address]),
      market: "SOUTH-AMERICA",
      buyer_style_ref: line_item[:material_code] || header[:generic_material] || header[:material] || header[:product] || "",
      packing_type: "",
      packing_option_flat_pack: "",
      color: header[:ffc_description] || "",
      size: line_item[:size] || "",
      total_qty: line_item[:quantity] || header[:total_po_quantity] || "",
      price: line_item[:unit_price] || "",
      units: line_item[:quantity] || header[:total_po_quantity] || "",
      delivery_terms: "FOB",
      zone: ""
    }
  end

  def extract_buyer_name(invoice_to_data)
    return "" unless invoice_to_data && invoice_to_data[:lines]

    invoice_to_data[:lines].first || ""
  end

  def extract_country(address_data)
    return "" unless address_data

    address_data[:country] || ""
  end
end
