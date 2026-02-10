module Buyers
  module Barbour
    class Prompt
      def self.build
        <<~PROMPT
          You are an expert at extracting structured data from Purchase Order PDFs. Extract ALL Purchase Orders from this document.

          **CRITICAL INSTRUCTIONS:**
          1. Split documents by Order no. - each unique Order no. is a separate Purchase Order
          2. For each Order no., extract ONLY the fields listed below - set fields to empty string if not found
          3. Create one row per line item (size/quantity combination)
          4. DO NOT use default values unless I explicitly specify them
          5. READ CAREFULLY - extract the EXACT field specified, from the EXACT location specified
          6. ALL dates MUST be in DD-MM-YYYY format (e.g., "25-12-2024", not "25/12/2024" or "12-25-2024")

          **EXTRACT THESE FIELDS PER PO:**

          **Header Fields (same for all line items in a PO):**
          - "order_no": Extract from "Order no:" field from the document (e.g., "4461577")
          - "delivery_address": Extract from "Delivery Address:" field at the top of the document, find the country of city mentioned at the last line - Eg If it says Jarrow then use UK, If it says Netherland then use Europe, If it says Vietnam then use Asia and If it says US then use US (e.g., "Jarrow" -> "UK")

          **Line Item Fields (per size/quantity row):**
          - "item_number": Extract from "Item number:" field, and extract only the characters before the second time character appearance (e.g., if field is this "MSH5588IN32S" then return only "MSH5588" as this text appears before the second time character appearnace)
          - "colour": Extract from the Name for each size row, it is a combination of name and colour so return only the colour which will always be at last (e.g., "Indigo")
          - "size": Extract from the Item number for each size row, return only the last characters from the row which is size, the value should be like S, M, L, XL, XXL, XXXL (e.g., "MSH5588IN32S" -> "S")
          - "purch_price": Extract from the Purch Price for each size row (e.g., "15.90")
          - "quantity":  Extract from Order qty for each size row (e.g., "79")

          **CRITICAL LINE ITEM EXTRACTION RULES:**
          - The line items are listed under Rest of World section with rows like: Item number, Name, UPC, Order qty, U/M, Purch price, Ex-Factory Dt, Confirmed Dt and Line Total
          - Process row-by-row: For each Item number row, extract the colour from Name (e.g., "Indigo"), Item number, Order qty and Purch price.
          - Group all sizes under the same Item number as separate line items.

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
          - One object per Order no., with line_items array
          - Extract ALL line items with their actual Name, Item number, Order qty and Purch price.
          - Each Item number in the breakdown table should be a separate line item
          - ALL dates must be in DD-MM-YYYY format (day-month-year with dashes)
        INSTRUCTIONS
      end
    end
  end
end
