module Buyers
  module Kontoor
    class Prompt
      def self.build
        <<~PROMPT
          You are an expert at extracting structured data from Purchase Order PDFs. Extract ALL Purchase Orders from this document.

          **CRITICAL INSTRUCTIONS:**
          1. Split documents by PO - each unique PO Number is a separate Purchase Order
          2. For each PO, extract ONLY the fields listed below - set fields to empty string if not found
          3. Create one row per line item (size/quantity combination)
          4. DO NOT use default values unless I explicitly specify them
          5. READ CAREFULLY - extract the EXACT field specified, from the EXACT location specified

          **EXTRACT THESE FIELDS PER PO:**

          **Header Fields (same for all line items in a PO):**
          - "po_number": Extract from "PO:" field at the top of the document (e.g., "450169606600100")
          - "currency": Extract from "CURRENCY:" field (e.g., "USD")
          - "season": Extract from "SEASON/SEASON YR.:" field (e.g., "SS 2026")
          - "po_issue_date": Extract from "PO Issue Date:" field, parse it as MM/DD/YYYY format, add 3 days to the parsed date, and return it formatted as DD-MM-YYYY (e.g., convert "08/12/2025" to "15-08-2025"), outputting only the formatted date..
          - "payment_terms": Extract from "Payment Terms:" field (e.g., "Net 90 Days")
          - "shipment_mode": Extract from "Shipment Mode:" field (e.g., "Sea")
          - "current_crd_date": Extract from "Current CRD Date:" field, parse it as MM/DD/YYYY format, and return it formatted as DD-MM-YYYY (e.g., convert "11/17/2025" to "17-11-2025"), outputting only the formatted date.
          - "shipping_destination": Extract ONLY the country name from "Shipping Destination:" address (e.g., "Czech Republic")
          - "market": Extract from "EMEA Brexit EU or UK:" field (e.g., "EU")
          - "style": Extract from "Style:" field (e.g., "112375590")
          - "delivery_terms": Extract from "Shipment Terms:" field (e.g., "DAP JAZLOVICE DC (COLLECT)")

          **Line Item Fields (per size/quantity row):**
          - "color": Extract from the Color Description for each size row (e.g., "MOOD_INDIGO_PLAID")
          - "size": Extract from the size abbreviation in each row (e.g., "S", "M", "L")
          - "quantity": Extract from the "Current Quantity" column in each size row (e.g., "557", "249")
          - "price": Extract from the "Unit Cost" column in each size row (e.g., "9.3900"). Make sure you only extract the numeric value and not the currency symbol.

          **Line Item Fields (per size/quantity row):**
          - "final_destination": Extract from "Final Destination:" field (e.g., "FC01 Barnsley")
          - "supplier_ref": Extract from "Supplier Ref.:" field (e.g., "SS MURCIA")
          - "packing_method": Extract from "Packing Method:" field (e.g., "FLAT")
          - "website_colour": Extract from "Website Colour:" field (e.g., "BLUE", "BLACK")
          - "brand_size": Extract from "Brand Size:" field (e.g., "M", "L", "XL")
          - "quantity": Extract from "Current Quantity" column in each size row (e.g., "195", "111")
          - "unit_cost": Extract from "Unit Cost" column in each size row (e.g., "6.99", "9.66")

          **CRITICAL LINE ITEM EXTRACTION RULES:**
          - The line items are listed in a table format with rows like: Color Code Color Description Size Dimension UPC / EAN Original Quantity Current Quantity Open Quantity Unit Cost Total Cost
          - Process row-by-row: For each size-specific row, extract the combined color code and description (e.g., "B4698 MOOD_INDIGO_PLAID"), size, current quantity, and unit cost.
          - Group all sizes under the same color/style as separate line items.
          - Ignore total rows (e.g., "Total For Color:", "Grand Total").

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
          - Each size in the breakdown table should be a separate line item
        INSTRUCTIONS
      end
    end
  end
end
