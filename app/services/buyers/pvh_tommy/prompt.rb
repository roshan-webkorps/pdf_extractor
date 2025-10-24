module Buyers
  module PvhTommy
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
          - "po_number": Extract from "PO Number:" field at the top of the document
          - "product_division": Extract from "Product Division" field
          - "currency": Extract from "Currency" field (USD, EUR, etc.)
          - "pay_terms": Extract from "Pay Terms" field
          - "ship_mode": Extract from "Ship Mode" field
          - "style": Extract from the "Style #" field
          - "pack_method": Extract from the "Pack Method" field
          - "buyer": Extract the country name from "Buyer" field. It should be on the top left section of the PO.
          - "consignee": Extract the country name from "CONSIGNEE" field. It would be written in a vertical manner in the PO.
          - "buyer_order_date": Extract from "PO Issue Date" field. Convert format from YYYY/MM/DD to DD.MM.YYYY (e.g., "2025/08/18" becomes "18.08.2025")
          - "buyer_delivery_date": Extract from "At Cons Date" field. Convert format from YYYYMMDD to DD.MM.YYYY (e.g., "20251203" becomes "03.12.2025"). If not present, set to empty string.
          - "ffc_description": Extract from "Color Description" column
          - "inco_terms": Extract from "Inco Terms" column

          **Line Item Fields (per size/quantity row):**
          - "size": Extract from "Size/Dim" column header (XS, S, M, L, XL, XXL, etc.)
          - "quantity": Extract quantity value for each size from the "Qty" row in size breakdown table
          - "cost": Extract cost value for each size from the "Cost" row in size breakdown table
          - "total_units": Extract the total units value that appears at the BOTTOM of the SPECIFIC size breakdown table that this line item belongs to. Look for "T o t a l Units [NUMBER]" or "Total Units [NUMBER]" at the bottom of each table. If a PO has multiple tables (for different colors/styles), each table has its own total - use the correct total for each group. Extract only the numeric value and remove commas.

          **IMPORTANT FOR DATE EXTRACTION:**
          - PO Issue Date dates come in format YYYY/MM/DD or YYYYMMDD
          - Always convert to DD.MM.YYYY format

          **IMPORTANT FOR SIZE EXTRACTION:**
          - PO has a size breakdown table with columns: XS, S, M, L, XL, XXL, etc.
          - Each column with a quantity should be a separate line item
          - Extract the exact size from the column header

          **IMPORTANT FOR TOTAL UNITS:**
          - If a PO has a SINGLE size breakdown table: all line items get the same total_units value from that table
          - If a PO has MULTIPLE size breakdown tables (different Line#, different colors, etc.): each group of line items gets the total_units from ITS OWN table
          - Example: Table 1 (Color A) has sizes XS,S,M,L with "Total 657 Units" → all Color A line items get "657"
          - Example: Table 2 (Color B) has sizes XS,S,M,L with "Total 980 Units" → all Color B line items get "980"
          - DO NOT sum all tables together - use the specific table's total for its line items

          **EXAMPLE OUTPUT FORMAT:**
          [
            {
              "po_number": "4300158881",
              "buyer_company": "PVH CORP",
              "season": "2026",
              "currency": "USD",
              "buyer_order_date": "18.08.2025",
              "buyer_delivery_date": "03.12.2025",
              "ship_under_po_ref": "MW42860",
              "delivery_country": "UNITED STATES",
              "ffc_description": "Swt Bl / Strp",
              "line_items": [
                {
                  "variant_material_code": "MW0MW42860",
                  "base_material_code": "MW42860",
                  "description": "FLEX POPLIN STP SS SHIRT",
                  "size": "XS",
                  "quantity": "11",
                  "item_total": "114.40",
                  "total_units": "907"
                },
                {
                  "variant_material_code": "MW0MW42860",
                  "base_material_code": "MW42860",
                  "description": "FLEX POPLIN STP SS SHIRT",
                  "size": "S",
                  "quantity": "32",
                  "item_total": "332.80",
                  "total_units": "407"
                },
                {
                  "variant_material_code": "MW0MW42860",
                  "base_material_code": "MW42860",
                  "description": "FLEX POPLIN STP SS SHIRT - Color B",
                  "size": "XS",
                  "quantity": "7",
                  "item_total": "72.80",
                  "total_units": "420"
                },
                {
                  "variant_material_code": "MW0MW42860",
                  "base_material_code": "MW42860",
                  "description": "FLEX POPLIN STP SS SHIRT - Color B",
                  "size": "S",
                  "quantity": "23",
                  "item_total": "239.20",
                  "total_units": "320"
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
          - Each size in the breakdown table should be a separate line item
          - Remember: If multiple tables exist in a PO, each table group has its own "total_units" value
        INSTRUCTIONS
      end
    end
  end
end
