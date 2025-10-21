module Buyers
  module Levis
    class Prompt
      def self.build
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

          #{common_output_instructions}
        PROMPT
      end

      private

      def self.common_output_instructions
        <<~INSTRUCTIONS
          **IMPORTANT:**
          - Return ONLY valid JSON array
          - No explanations or markdown
          - Empty string for missing fields, never null
          - One object per PO, with line_items array
          - Extract ALL line items with their actual sizes and quantities
          - Always use BASE material codes for "ship_under_po_ref" (remove size suffixes)
          - For dates, be very specific: "Original ExfacDate" NOT "Planned Del. Date"
        INSTRUCTIONS
      end
    end
  end
end
