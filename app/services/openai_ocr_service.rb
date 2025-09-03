# app/services/openai_ocr_service.rb
class OpenaiOcrService
  require "base64"

  def initialize(file_path)
    @file_path = file_path
    @client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
  end

  def extract_text
    # Build focused prompt for PO extraction
    prompt = build_po_extraction_prompt

    # Send to OpenAI (now uploads file and uses file_id)
    extracted_data = send_openai_request(nil, prompt)

    # Convert to Excel format
    if extracted_data.is_a?(Array) && extracted_data.any?
      excel_data = convert_to_excel_format(extracted_data)

      Rails.logger.info "OpenAI extracted #{extracted_data.length} POs with #{excel_data.length} total line items"
      excel_data
    else
      Rails.logger.error "OpenAI extraction failed or returned no data"
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

      **CRITICAL OUTPUT FORMAT - MUST BE AN ARRAY:**
      [
        {
          "po_number": "2500043993",
          "buyer_company": "LEVI STRAUSS DE MEXICO",
          "season": "251",
          "currency": "USD",
          "buyer_order_date": "17.06.2024",
          "buyer_delivery_date": "07.12.2024",
          "ship_under_po_ref": "72625-0110",
          "delivery_country": "Argentina",
          "unit_price": "8.03",
          "ffc_description": "",
          "line_items": [...]
        },
        {
          "po_number": "2500045247",
          "buyer_company": "LEVI STRAUSS DE MEXICO",#{' '}
          "season": "251",
          "currency": "USD",
          "buyer_order_date": "21.06.2024",
          "buyer_delivery_date": "19.10.2024",
          "ship_under_po_ref": "52669-0457",
          "delivery_country": "Bolivia",
          "unit_price": "7.00",
          "ffc_description": "",
          "line_items": [...]
        }
      ]

      **RETURN ARRAY FORMAT - NOT SINGLE OBJECT. EXTRACT ALL POS IN THE DOCUMENT.**
    PROMPT
  end

  def send_openai_request(base64_content, prompt)
    retries = 0
    max_retries = 3

    begin
      response = @client.chat(
        parameters: {
          model: "gpt-4o-mini",  # Good choice - faster than gpt-4o
          messages: [
            {
              role: "user",
              content: [
                { type: "text", text: prompt },
                {
                  type: "file",
                  file: {
                    filename: File.basename(@file_path),
                    file_data: "data:application/pdf;base64,#{Base64.strict_encode64(File.binread(@file_path))}"
                  }
                }
              ]
            }
          ],
          max_tokens: 6144,  # Reduced from 8192 for faster processing
          temperature: 0.1
        }
      )

      if response.dig("choices", 0, "message", "content")
        raw_response = response.dig("choices", 0, "message", "content")
        Rails.logger.info "Raw OpenAI response: #{raw_response[0..200]}..."

        json_str = raw_response[/```json\s*(.*?)\s*```/m, 1]&.strip || raw_response.strip
        parsed_data = JSON.parse(json_str)

        final_data = parsed_data.is_a?(Array) ? parsed_data : [ parsed_data ]
        Rails.logger.info "OpenAI extracted #{final_data.length} POs"
        final_data
      else
        Rails.logger.error "No content in OpenAI response"
        []
      end

    rescue Net::ReadTimeout => e
      retries += 1
      if retries <= max_retries
        Rails.logger.warn "OpenAI timeout (attempt #{retries}/#{max_retries}): #{e.message}"
        sleep(5 * retries)  # 5, 10, 15 seconds
        retry
      else
        Rails.logger.error "OpenAI timed out after #{max_retries} retries"
        []
      end
    rescue => e
      retries += 1
      if retries <= max_retries
        Rails.logger.warn "OpenAI request failed (attempt #{retries}/#{max_retries}): #{e.message}"
        sleep(2 ** retries)
        retry
      else
        Rails.logger.error "OpenAI failed after #{max_retries} retries: #{e.message}"
        []
      end
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
