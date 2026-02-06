module Buyers
  module Bestseller
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

          **EXTRACT THESE FIELDS PER PO:**

          **Header Fields (same for all line items in a PO):**
          - "order_number": Extract from "Order no:" field at the top of the document (e.g., "AQUMHA4460494")
          - "price_per_item_currency": Extract ONLY currency from "Price per item:" field is below Quantity / Price section (e.g., "EUR")
          - "price_per_item": Extract ONLY price from "Price per item:" field is below Quantity / Price section (e.g., "7.00")
          - "collection": Extract from "Collection:" field at the top of the document (e.g., "NOOS ( NOOS )")
          - "1_print_date": Extract from "1 Print Date:" field, parse it as DD-MM-YYYY format, and return it formatted as DD-MM-YYYY (e.g., convert "September 24, 2025" to "24-09-2025"), outputting only the formatted date.
          - "transportation": Extract from "Transportation:" field, field is under PAYMENT / TRANSPORTATION section (e.g., "BY SEA")
          - "delivery_buyer_order_ref": Extract from "Cargo closing date (CCD):" field, field is under DATES section, parse it as DD-MM-YYYY format, subtract the date 21 days before, and return it formatted as DD-MM-YYYY (e.g., convert "2026-01-28" to "07-01-2026"), outputting only the formatted date.
          - "buyer_delivery_date": Extract from "Cargo closing date (CCD):" field, field is under DATES section, parse it as DD-MM-YYYY format, and return it formatted as DD.MM.YYYY (e.g., convert "2026-01-28" to "28.01.2026"), outputting only the formatted date.
          - "oc_delivery_date": Extract from "Cargo closing date (CCD):" field, field is under DATES section, parse it as DD-MM-YYYY format, subtract the date 21 days before, and return it formatted as DD-MM-YYYY (e.g., convert "2026-01-28" to "07-01-2026"), outputting only the formatted date.
          - "destination": Extract from "Destination:" field at the top of the document (e.g., "DENMARK")
          - "market": Extract from "Destination:" field at the top of the document, find the continent of destination - Eg if Denmark then it becomes Europe (e.g., "DENMARK" -> "EUROPE")
          - "style_information_name": Extract from "Name:" field, field is under Style Information section, (e.g., "JPRBLUHARVEY OXFORD L/S SHIRT NOOS")

          **Line Item Fields (per size/quantity row):**
          - "colour": Extract from the Color + variant name for each size row (e.g., "Chambray Blue")
          - "summary_buyer_order_ref": Add the order number key's value in above colour key value (e.g., "AQUMHA4460494 - Chambray Blue")
          - "size": Extract from the Size EU abbreviation in each row (e.g., "XS", "S", "M", "L", "XL", "XXL")
          - "quantity": Get the quantity for each colour and size from ORDER TOTAL table (e.g., "26", "182", "416")

          **CRITICAL LINE ITEM EXTRACTION RULES:**
          - The line items are listed in ORDER TOTAL under SUMMING UP THE PRODUCTION section with rows like: Length, Color + variant name, Business Model, Size EU, Total.
          - Process row-by-row: For each Size EU row, extract the colour from Color + variant name (e.g., "Chambray Blue"), size eu.
          - Group all sizes under the same Size EU as separate line items.

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
          - Extract ALL line items with their actual Color + variant name and size EU
          - Each Size EU in the breakdown table should be a separate line item
        INSTRUCTIONS
      end
    end
  end
end
