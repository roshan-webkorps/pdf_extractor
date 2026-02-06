module Buyers
  module SuperdryAustralia
    class Prompt
      def self.build
        <<~PROMPT
          You are an expert at extracting structured data from Purchase Order PDFs. Extract ALL Purchase Orders from this document.

          **CRITICAL INSTRUCTIONS:**
          1. Split documents by PURCHASE ORDER NO - each unique PURCHASE ORDER NO is a separate Purchase Order
          2. For each PURCHASE ORDER NO, extract ONLY the fields listed below - set fields to empty string if not found
          3. Create one row per line item (size/quantity combination)
          4. DO NOT use default values unless I explicitly specify them
          5. READ CAREFULLY - extract the EXACT field specified, from the EXACT location specified

          **EXTRACT THESE FIELDS PER PO:**

          **Header Fields (same for all line items in a PO):**
          - "purchase_order_number": Extract from "PURCHASE ORDER NO::" field at the top right corner of the document (e.g., "570394")
          - "currency": Extract currency from "Currency:" field (e.g., "GBP")
          - "po_create_date": Extract from "PO Create Date:" field at the top right corner of the document (e.g., "11-08-2025").

          **Line Item Fields (per size/quantity row):**
          - "buyer_delivery_date": Extract the date from Shipment Date for each size row (e.g., "3-02-2026 ")
          - "oc_delivery_date": Extract the date from Shipment Date for each size row and subtract 7 days (e.g., "07/10/2025" -> "30-09-2025")
          - "style_no": Extract the from Style No for each size row (e.g., "SM63SS1O")
          - "colour": Extract from the COLOUR CODE and COLOUR DESC for each size row, and return both values (e.g., "HTE - HARBOUR CHECK WHITE")
          - "size": Extract the values from Size for each row (e.g., "S", "M", "L", "XL", "2XL", "3XL")
          - "quantity": Extract the quantity from FG ORDER QTY each size row (e.g., "60", "155")
          - "price": Extract from the Price for each size row (e.g., "8.50")

          **CRITICAL LINE ITEM EXTRACTION RULES:**
          - The line items are listed in a table like structure with column named as STYLE LINE NO, PO LINE NO, STYLE NO, STYLE DESCRIPTION, COLOUR CODE, COLOUR DESC, SIZE, DIM, SUPPLIER ART NO, FG ORDER QTY, PRICE, CURR, UOM, PO LINE VALUE, FG CTN QTY, NO OF CTN, SHIPMENT DATE, EAN/APN, FREIGHT MODE
          - Process row-by-row: For each size row, extract the COLOUR CODE and COLOUR DESC (e.g., "HTE - HARBOUR CHECK WHITE"), Style no, Shipment Date, Price, FG ORDER QTY
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
          - One object per PURCHASE ORDER NO, with line_items array
          - Extract ALL line items with their COLOUR CODE and COLOUR DESC, Style no, Shipment Date, Price, FG ORDER QTY
          - Each Size in the breakdown table should be a separate line item
        INSTRUCTIONS
      end
    end
  end
end
