module Buyers
  module SuperdryUk
    class Prompt
      def self.build
        <<~PROMPT
          You are an expert at extracting structured data from Purchase Order PDFs. Extract ALL Purchase Orders from this document.

          **CRITICAL INSTRUCTIONS:**
          1. Split documents by PO No - each unique PO No is a separate Purchase Order
          2. For each PO No, extract ONLY the fields listed below - set fields to empty string if not found
          3. Create one row per line item (size/quantity combination)
          4. DO NOT use default values unless I explicitly specify them
          5. READ CAREFULLY - extract the EXACT field specified, from the EXACT location specified

          **EXTRACT THESE FIELDS PER PO:**

          **Header Fields (same for all line items in a PO):**
          - "po_no": Extract from "PO No:" field at the top right corner of the document (e.g., "1113610")
          - "supplier_currency": Extract currency from "Supplier Currency:" field at the top right corner of the document (e.g., "GBP")
          - "season_year": Extract from "Season Year:" field at the top right corner of the document (e.g., "SS26")
          - "po_date": Extract from "PO Date:" field at the top of the document (e.g., "09-06-2025").

          **Line Item Fields (per size/quantity row):**
          - "buyer_delivery_date": Extract the date from Handover for each size row (e.g., "07-10-2025")
          - "oc_delivery_date": Extract the date from Handover for each size row and subtract 7 days (e.g., "07/10/2025" -> "30-09-2025")
          - "style": Extract the from Style for each size row (e.g., "M4010737A")
          - "colour": Extract from the Colour Description for each size row (e.g., "Montauk Check Red ( CVJ)")
          - "size": Extract the values from the columns between Fit and Handover in for each row (e.g., "XXS", "XS", "S", "M", "L", "XL", "2XL", "3XL", "4XL", "5XL", "6XL")
          - "quantity": Extract the quantity from the below of each size row (e.g., "60", "155")
          - "cost": Extract from the Cost for each size row (e.g., "9.10")

          **CRITICAL LINE ITEM EXTRACTION RULES:**
          - The line items are listed in a table like structure with column named as Style, Garment Description, Colour Description, Fit, XXS, XS, S, M, L, XL, 2XL, 3XL, 4XL, 5XL, 6XL, Handover, Packs, Qty, Cost, Total
          - Process row-by-row: For each size row, extract the Colour Description (e.g., "Montauk Check Red ( CVJ)"), Style, Handover, Cost
          - Group all sizes under the same size as separate line items.

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
          - One object per PO No, with line_items array
          - Extract ALL line items with their Colour Description, Style, Handover, Cost
          - Each Size in the breakdown table should be a separate line item
        INSTRUCTIONS
      end
    end
  end
end
