class GeminiOcrService
  require "base64"
  require "httparty"

  def initialize(file_path)
    @file_path = file_path
  end

  def extract_text
    # Read and encode the PDF
    pdf_content = File.binread(@file_path)
    base64_content = Base64.strict_encode64(pdf_content)

    # Build focused prompt for PO extraction
    prompt = build_po_extraction_prompt

    # Send to Gemini
    extracted_data = send_gemini_request(base64_content, prompt)

    # Convert to Excel format
    if extracted_data.is_a?(Array) && extracted_data.any?
      excel_data = convert_to_excel_format(extracted_data)

      Rails.logger.info "Gemini extracted #{extracted_data.length} POs with #{excel_data.length} total line items"
      excel_data
    else
      Rails.logger.error "Gemini extraction failed or returned no data"
      []
    end
  end

  private

  def build_po_extraction_prompt
    <<~PROMPT
      You are an expert at extracting structured data from Purchase Order PDFs. Extract ALL Purchase Orders from this document.

      **CRITICAL INSTRUCTIONS:**
      1. Split documents by PO NUMBER - each unique PO NUMBER is a separate Purchase Order
      2. For each PO, extract ONLY the fields listed below - set fields to empty string if not found
      3. Create one row per line item (size/quantity combination)
      4. DO NOT use default values unless I explicitly specify them

      **EXTRACT THESE FIELDS PER PO:**

      **Header Fields (same for all line items in a PO):**
      - "po_number": Extract from "Purchase Order#", "PO NUMBER", or similar
      - "buyer_company": Look for "Invoice To" section first. If "Invoice To" section exists, extract the company name from there. If "Invoice To" section does NOT exist, then extract the company name from the top-left area of the document (usually the first company name listed below any logos/headers). Do NOT extract from "IMPORTER OF RECORD" section under any circumstances.
      - "season": Extract from "Season" or "Season Code" (numbers only)
      - "currency": Extract from "Currency" or "PO Currency" (USD, EUR, etc.)
      - "buyer_order_date": Extract from "DocDate" or "PO Release Date" (format: DD.MM.YYYY)
      - "buyer_delivery_date": Extract ONLY from "Planned HOD" or "Original Ex-facDate" or "Planned Ex-fac Date" column. DO NOT use "Planned Del. Date", "Planned Delivery Date", or "Planned Cut Date". If "Planned HOD" or "Original Ex-facDate" or "Planned Ex-fac Date" is not present, set to empty string.
      - "ship_under_po_ref": Extract from "Generic Material", "Material", or "Product" columns - use the BASE code WITHOUT size suffixes (e.g., "72625-0110" not "72625-0110M")
      - "delivery_country": Extract ONLY the country name from "Delivery Address"
      - "unit_price": Extract from "PO Unit Price"
      - "ffc_description": Extract from "FFC DESCRIPTION" field only. If "FFC DESCRIPTION" field is not present in the document, set to empty string. Do NOT use "FFC CODE", "Description", or any other field.

      **Line Item Fields (per size/quantity row):**
      - "variant_material_code": Full material code with size suffix from line items (e.g., "72625-0110M")
      - "base_material_code": BASE material code WITHOUT size suffix (e.g., "72625-0110")
      - "description": Product description
      - "size": Size (M, L, XL, CH, EG, G, etc.)
      - "quantity": Quantity for this size
      - "item_total": Total value for this line item

      **IMPORTANT FOR DATE EXTRACTION:**
      - "buyer_delivery_date" should ONLY come from "Planned HOD" or "Original Ex-facDate" or "Planned Ex-fac Date"
      - IGNORE "Planned Del. Date", "Planned Delivery Date", "Planned Cut Date"
      - If no "Planned HOD" or "Original Ex-facDate" or "Planned Ex-fac Date" column exists, leave buyer_delivery_date empty

      **IMPORTANT FOR COLOR EXTRACTION:**
      - "ffc_description" should ONLY come from "FFC DESCRIPTION"
      - IGNORE "FFC CODE", "Description", "Material Description"
      - If no "FFC DESCRIPTION" column exists, leave ffc_description empty

      **IMPORTANT FOR MATERIAL CODES:**
      - "ship_under_po_ref" should always be the BASE code from "Generic Material" column (without letters at the end)
      - "variant_material_code" in line items can have size suffixes
      - "base_material_code" in line items should match "ship_under_po_ref"

      **EXAMPLE OUTPUT FORMAT:**
      [
        {
          "po_number": "4531021625",
          "buyer_company": "Levi Strauss Global Trading Co. Ltd",
          "season": "251",
          "currency": "USD",
          "buyer_order_date": "13.06.2024",
          "buyer_delivery_date": "10.10.2024",
          "ship_under_po_ref": "A5772-0014",
          "delivery_country": "KOREA",
          "unit_price": "9.78",
          "ffc_description": "WASHINGTON STRIPE II",
          "line_items": [
            {
              "variant_material_code": "A5772-0014",
              "base_material_code": "A5772-0014",
              "description": "CLASSIC WORKER -WORKWEAR WASHINGTON STRI",
              "size": "M",
              "quantity": "150",
              "item_total": "1467.00"
            }
          ]
        }
      ]

      **IMPORTANT:**
      - Return ONLY valid JSON array
      - No explanations or markdown
      - Empty string for missing fields, never null
      - One object per PO, with line_items array
      - Extract ALL line items with their actual sizes and quantities
      - Always use BASE material codes for "ship_under_po_ref" (remove size suffixes)
      - For dates, be very specific: "Original ExfacDate" NOT "Planned Del. Date"
    PROMPT
  end

  def send_gemini_request(base64_data, prompt)
    retries = 0
    max_retries = 5

    begin
      Rails.logger.info "Sending PDF to Gemini 2.5 Flash for extraction..."

      response = HTTParty.post(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=#{ENV['GOOGLE_GEMINI_API_KEY']}",
        headers: { "Content-Type" => "application/json" },
        body: {
          contents: [
            {
              parts: [
                { text: prompt },
                {
                  inlineData: {
                    mimeType: "application/pdf",
                    data: base64_data
                  }
                }
              ]
            }
          ],
          generationConfig: {
            temperature: 0.1,
            maxOutputTokens: 8192
          }
        }.to_json
      )

      if response.code == 200
        raw_response = JSON.parse(response.body).dig("candidates", 0, "content", "parts", 0, "text")

        if raw_response
          json_str = raw_response[/```json\s*(.*?)\s*```/m, 1]&.strip || raw_response.strip
          parsed_data = JSON.parse(json_str)
          Rails.logger.info "Gemini successfully extracted #{parsed_data.length} POs"
          parsed_data
        else
          Rails.logger.error "Empty response from Gemini"
          []
        end
      elsif response.code == 503
        raise StandardError.new("Service overloaded (503)")
      else
        Rails.logger.error "Gemini API failed (#{response.code}): #{response.body}"
        []
      end

    rescue JSON::ParserError => e
      Rails.logger.error "Failed to parse Gemini JSON response: #{e.message}"
      []
    rescue StandardError => e
      if e.message.include?("Service overloaded") || e.message.include?("503")
        retries += 1
        if retries <= max_retries
          Rails.logger.warn "Gemini overloaded, retrying in 5 seconds (attempt #{retries}/#{max_retries})"
          sleep(5)
          retry
        else
          Rails.logger.error "Gemini failed after #{max_retries} retries: #{e.message}"
          []
        end
      else
        Rails.logger.error "Gemini request failed: #{e.message}"
        []
      end
    rescue => e
      Rails.logger.error "Gemini request failed: #{e.message}"
      []
    end
  end

  def convert_to_excel_format(gemini_data)
    excel_rows = []

    gemini_data.each do |po|
      header = po
      line_items = po["line_items"] || []

      if line_items.empty?
        excel_rows << build_excel_row(header, {})
      else
        line_items.each do |item|
          excel_rows << build_excel_row(header, item)
        end
      end
    end

    excel_rows
  end

  def build_excel_row(header, line_item)
    {
      "factory" => "",
      "ship_under_po_ref" => header["ship_under_po_ref"] || "",
      "article" => "",
      "buyer" => header["buyer_company"] || "",
      "buyer_division_dept" => "",
      "currency" => header["currency"] || "",
      "season" => header["season"] || "",
      "country_of_origin" => "INDIA",
      "place_of_receipt_by_pre_carrier" => "",
      "prod_capacity_booking_no" => "",
      "order_initiation_date" => "",
      "payment_terms" => "TT 90 DAYS",
      "buyer_po_num" => header["po_number"] || "",
      "summary_buyer_order_ref" => header["po_number"] || "",
      "market_buyer_order_ref" => header["ship_under_po_ref"] || "",
      "destination_buyer_order_ref" => header["delivery_country"]&.upcase || "",
      "delivery_buyer_order_ref" => header["po_number"] || "",
      "buyer_order_date" => header["buyer_order_date"] || "",
      "order_type" => "Confirmed",
      "mode_of_shipment" => "SEA",
      "buyer_delivery_date" => header["buyer_delivery_date"] || "",
      "oc_delivery_date" => header["buyer_delivery_date"] || "",
      "pcd_date" => "",
      "original_gac_date" => "",
      "gac_date" => "",
      "raw_material_eta" => "",
      "country_of_final_destination" => header["delivery_country"]&.upcase || "",
      "final_destination" => header["delivery_country"]&.upcase || "",
      "market" => "SOUTH-AMERICA",
      "buyer_style_ref" => header["ship_under_po_ref"] || "",
      "packing_type" => "",
      "packing_option_flat_pack" => "",
      "color" => header["ffc_description"] || "",
      "size" => line_item["size"] || "",
      "total_qty" => line_item["quantity"] || "",
      "price" => header["unit_price"] || "",
      "units" => line_item["quantity"] || "",
      "delivery_terms" => "FOB",
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
