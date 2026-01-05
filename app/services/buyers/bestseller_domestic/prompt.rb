module Buyers
  module BestsellerDomestic
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
          - "po_number": Extract from "PO number:" field at the top of the document (e.g., "4500154132")
          - "communication_address": Extract from "Communication address:" field, If Communication address is "BEST UNITED INDIA COMFORTS PVT LTD." then return the value as "Bestseller India J&J" otherwise return Communication address from the first line (e.g., "BEST UNITED INDIA COMFORTS PVT LTD.")
          - "currency": Extract currency from "Currency:" field, it is at the second row's last value of a table table whose columns are in this manner: ARTICLE, Article description Customs code Fabric composition Construction type Gender Article group Country of origin, Price per unit, Total unit, Net Value, Currency (e.g., "INR")
          - "po_date": Extract from "PO Date:" field at the top of the document (e.g., "11.04.2025").
          - "goods_ready_date": Extract from "Goods ready date:" field (e.g., "20.01.2026")
          - "oc_delivery_date": Extract from "Goods ready date:" field, subtract the date 21 days before (e.g., convert "20.01.2026" to "30.12.2025"), outputting only the converted date.
          - "article_description": Extract from "Article Description:" field, it is at the second row's first value of a table whose columns are in this manner: ARTICLE, Article description Customs code Fabric composition Construction type Gender Article group Country of origin, Price per unit, Total unit, Net Value, Currency (e.g., "JJOR ITALY SHIRT SS")
          - "vcp_to_be": Extract from "VCP to be:" field (e.g., "760")

          **Line Item Fields (per size/quantity row):**
          - "colour": Extract from the ID / Colour for each size row (e.g., "Cloud Dancer")
          - "size": Extract from the Size abbreviation in each row (e.g., "XS", "S", "M", "L", "XL", "XXL")
          - "quantity": Extract ONLY quantity from for each size row (e.g., "61")

          **CRITICAL LINE ITEM EXTRACTION RULES:**
          - The line items are listed in a table like structure with column named as Item, Article variant, ID / Colour, Size, Quantity, IGST, IGST Rate (%), MRP, EAN Code, HSN
          - Process row-by-row: For each Article varient row, extract the colour from ID / Colour name (e.g., "Iceberg Green"), size, quantity.
          - Group all sizes under the same Article varient as separate line items.

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
          - One object per PO number, with line_items array
          - Extract ALL line items with their actual ID / Colour name, size and quantity
          - Each Article varient in the breakdown table should be a separate line item
        INSTRUCTIONS
      end
    end
  end
end
