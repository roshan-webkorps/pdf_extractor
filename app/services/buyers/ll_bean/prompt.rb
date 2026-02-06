module Buyers
  module LlBean
    class Prompt
      def self.build
        <<~PROMPT
          You are an expert at extracting structured data from Purchase Order PDFs. Extract ALL Purchase Orders from this document.

          **CRITICAL INSTRUCTIONS:**
          1. Split documents by PO number - each unique PO number is a separate Purchase Order
          2. For each PO number, extract ONLY the fields listed below - set fields to empty string if not found
          3. Create one row per line item (size/quantity combination)
          4. DO NOT use default values unless I explicitly specify them
          5. READ CAREFULLY - extract the EXACT field specified, from the EXACT location specified

          **EXTRACT THESE FIELDS PER PO:**

          **Header Fields (same for all line items in a PO):**
          - "po": Extract from "PO #:" field at the top of the document (e.g., "45560679")
          - "delivery_address": Extract from "Delivery address:" field, return the last word of the delivery address which is country (e.g., "US")
          - "season_year": Extract from "Season Year:" field (e.g., "Spring 2026")
          - "item_id": Extract from "ITEM ID" field which is at the starting of the table, it is combination of id and description but you should return only id (e.g., "525893").
          - "buyer_delivery_date": Extract from "Transfer date:" field, the date is in MM/DD/YYYY return the converted date in DD-MM-YYYY (e.g., "11/19/25" -> "19-11-25")
          - "oc_delivery_date": Extract from "Transfer date:" field, the date is in MM/DD/YYYY return the converted date in DD-MM-YYYY and subtract 21 days (e.g., "11/19/25" -> "29-10-25")
          - "item_id_description": Extract from "ITEM ID" field which is at the starting of the table, it is combination of id and description but you should return only description (e.g., "Snwshd Crdry Shrt LS SFF Pl M R").

          **Line Item Fields (per size/quantity row):**
          - "ship_mode": Extract from SHIP MODE for each size row, if the value is S return 'Sea' and is the value is A the 'Air' (e.g., "S" -> "Sea", "A" -> "Air")
          - "colour": Extract from the COLOR ID and COLOR DESCRIPTION for each size row  and combine them both (e.g., "299 Thyme")
          - "size": Extract from the column besides SIZE ID abbreviation in each row (e.g., "S", "M", "L", "XL", "XXL", "XXXL")
          - "quantity": Extract from QTY for each size row (e.g., "61", "84")
          - "purchase_price": Extract from PURCHASE PRICE for each size row (e.g., "14.50")

          **CRITICAL LINE ITEM EXTRACTION RULES:**
          - The line items are listed in a table like structure with column named as COLOR ID, COLOR DESCRIPTION, SIZE ID, DESCRIPTION, LLB SKU, PO LINE#, Ship Mode, VENDOR STYLE, VENDOR UPC, QTY ,PURCHASE PRICE, TOTAL COST, PRICE, PREP TYPE
          - Process row-by-row: For each COLOR ID and SIZE ID row, extract the COLOR ID and COLOR DESCRIPTION (e.g., "299 Thyme"), SIZE, QTY, PURCHASE PRICE, SHIP MODE
          - Group all sizes under the same COLOR ID and SIZE ID as separate line items.
          - The line items are separated into different pages for different color with their sizes.

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
          - One object per PO , with line_items array
          - Extract ALL line items with their COLOR ID and COLOR DESCRIPTION, SIZE, QTY, PURCHASE PRICE, SHIP MODE
          - Each Article varient in the breakdown table should be a separate line item
        INSTRUCTIONS
      end
    end
  end
end
