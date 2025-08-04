class ExcelExportService
  def initialize(documents = [])
    @documents = Array(documents)
  end

  def generate
    package = Axlsx::Package.new
    workbook = package.workbook
    worksheet = workbook.add_worksheet(name: "Purchase Orders")

    add_header_row(worksheet)
    add_data_rows(worksheet)

    package
  end

  private

  def add_header_row(worksheet)
    headers = [
      "Factory",
      "Ship Under PO Ref",
      "Article",
      "Buyer",
      "Buyer Division/Dept",
      "Currency",
      "Season",
      "Country of Origin",
      "Place of Receipt by Pre-Carrier",
      "Prod. Capacity Booking No",
      "Order Initiation Date",
      "Payment Terms",
      "Buyer PO Num",
      "Summary Buyer Order Ref",
      "Market Buyer Order Ref",
      "Destination Buyer Order Ref",
      "Delivery Buyer Order Ref",
      "Buyer Order Date",
      "Order Type",
      "Mode of Shipment",
      "Buyer Delivery Date",
      "OC Delivery Date",
      "PCD Date",
      "Original GAC Date",
      "GAC Date",
      "Raw Material ETA",
      "Country of Final Destination",
      "Final Destination",
      "Market",
      "Buyer Style Ref.",
      "Packing Type",
      "Packing Option/Flat Pack)",
      "Color",
      "Size",
      "Total Qty",
      "Price",
      "Units",
      "Delivery Terms",
      "Zone"
    ]

    worksheet.add_row headers, style: header_style(worksheet)
  end

  def add_data_rows(worksheet)
    @documents.each do |document|
      next unless document.completed? && document.excel_data.present?

      document.excel_data.each do |row_data|
        worksheet.add_row([
          row_data["factory"],
          row_data["ship_under_po_ref"],
          row_data["article"],
          row_data["buyer"],
          row_data["buyer_division_dept"],
          row_data["currency"],
          row_data["season"],
          row_data["country_of_origin"],
          row_data["place_of_receipt_by_pre_carrier"],
          row_data["prod_capacity_booking_no"],
          row_data["order_initiation_date"],
          row_data["payment_terms"],
          row_data["buyer_po_num"],
          row_data["summary_buyer_order_ref"],
          row_data["market_buyer_order_ref"],
          row_data["destination_buyer_order_ref"],
          row_data["delivery_buyer_order_ref"],
          row_data["buyer_order_date"],
          row_data["order_type"],
          row_data["mode_of_shipment"],
          row_data["buyer_delivery_date"],
          row_data["oc_delivery_date"],
          row_data["pcd_date"],
          row_data["original_gac_date"],
          row_data["gac_date"],
          row_data["raw_material_eta"],
          row_data["country_of_final_destination"],
          row_data["final_destination"],
          row_data["market"],
          row_data["buyer_style_ref"],
          row_data["packing_type"],
          row_data["packing_option_flat_pack"],
          row_data["color"],
          row_data["size"],
          row_data["total_qty"],
          row_data["price"],
          row_data["units"],
          row_data["delivery_terms"],
          row_data["zone"]
        ])
      end
    end
  end

  def header_style(worksheet)
    worksheet.styles.add_style(
      bg_color: "4472C4",
      fg_color: "FFFFFF",
      b: true,
      alignment: { horizontal: :center, vertical: :center, wrap_text: true }
    )
  end
end
