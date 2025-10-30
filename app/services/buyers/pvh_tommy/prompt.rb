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
          5. READ CAREFULLY - extract the EXACT field specified, from the EXACT location specified
          6. IMPORTANT: A PO may have multiple Line# entries with different styles/colors - each size in each Line# is a separate line item

          **EXTRACT THESE FIELDS PER PO:**

          **Header Fields (same for all line items in a PO):**
          - "po_number": Extract from "PO Number:" field at the top of the document
          - "product_division": Extract from "Product Division" field (e.g., "Tommy Jeans Mens")
          - "currency": Extract from "Currency" field (USD, EUR, etc.)
          - "pay_terms": Extract from "Pay Terms" field (e.g., "Net 90 Days - No Deductions")
          - "ship_mode": Extract from "Ship Mode" field (e.g., "OCEAN")
          - "pack_method": Extract from the "Pack Method" field (e.g., "FOLDED-FLATPACK")

          - "buyer": Look at the "Buyer" section at the TOP LEFT of page 1. Extract ONLY the COUNTRY NAME from the address.
            Example: If you see "PVH CORP, 1001 FRONTIER RD, BRIDGEWATER, NJ, 08807, UNITED STATES" → extract "UNITED STATES"

          - "consignee": Look for the "CONSIGNEE" section (written VERTICALLY on the right side of page 2). Extract ONLY the COUNTRY NAME from this section.
            DO NOT confuse this with "Country Of Origin" which may show "INDIA" - that's the manufacturing country, not the consignee country.

          - "buyer_order_date": Extract from "PO Issue Date" field. Convert format from YYYY/MM/DD to DD.MM.YYYY (e.g., "2025/06/05" becomes "05.06.2025")
          - "buyer_delivery_date": Extract from "At Cons Date" field. Convert format from YYYYMMDD to DD.MM.YYYY (e.g., "20251107" becomes "07.11.2025"). If not present, set to empty string.
          - "inco_terms": Extract from "Inco Terms" field (e.g., "FOB,IN")

          **Line Item Fields (per size/quantity row):**
          - "style": Extract from the "Style #" field for THIS specific line item's table (e.g., "DM22411")
          - "size": Extract from "Size/Dim" column header (XS, S, M, L, XL, XXL, etc.)
          - "quantity": Extract quantity value for each size from the "Qty" row in size breakdown table
          - "cost": Extract cost value for each size from the "Cost" row in size breakdown table
          - "total_units": Extract from the "Total Units" value at the BOTTOM of THIS line item's size breakdown table
          - "ffc_description": CRITICAL - Extract the "Color Description" for THIS specific line item from its size breakdown table
            Example: Line# 10 table shows "Color Description: Black/Check" → extract "Black/Check" for all sizes in that table
            Example: Line# 20 table shows "Color Description: Ancnt Wht/Chck" → extract "Ancnt Wht/Chck" for all sizes in that table

          **CRITICAL EXTRACTION RULES:**
          1. For COUNTRY extraction: Always extract ONLY the country name (last line of address)
          2. For STYLE and COLOR DESCRIPTION: Each Line# has its own values - extract from that specific line item table
          3. For DATES: Always convert to DD.MM.YYYY format
          4. For TOTAL UNITS: Use the total from the specific table this line item belongs to

          **IMPORTANT FOR SIZE EXTRACTION:**
          - Each Line# has a size breakdown table with columns: XS, S, M, L, XL, XXL, etc.
          - Each column with a quantity should be a separate line item
          - All line items from the same Line# table share the same style, color description, and total_units

          **IMPORTANT FOR TOTAL UNITS:**
          - Each size breakdown table (each Line#) has its own "Total Units" at the bottom
          - Example: Line# 10 table shows "Total Units: 75" → all 7 sizes from that table get "75"
          - Example: Line# 20 table shows "Total Units: 90" → all 7 sizes from that table get "90"
          - DO NOT sum all tables together - use the specific table's total for its line items

          **CRITICAL EXAMPLES:**

          **Example 1 - Consignee Country (NOT manufacturing origin):**
          You will see:
          - Country Of Origin: IN-India (manufacturing location)
          - CONSIGNEE section: UNITED STATES (destination)

          Extract "consignee": "UNITED STATES" ✓ (NOT "INDIA" ✗)

          **Example 2 - Style and Color Per Line Item:**

          Line# 10 table:
          Style #: DM22411
          Color Code: BDS | Color Description: Black/Check
          Sizes: XS(4), S(9), M(21), L(20), XL(12), XXL(7), 3XL(2)
          Total Units: 75

          Line# 20 table:
          Style #: DM22411
          Color Code: YBH | Color Description: Ancnt Wht/Chck
          Sizes: XS(5), S(11), M(25), L(24), XL(14), XXL(9), 3XL(2)
          Total Units: 90

          Result:
          - First 7 line items have "style": "DM22411", "ffc_description": "Black/Check", "total_units": "75"
          - Next 7 line items have "style": "DM22411", "ffc_description": "Ancnt Wht/Chck", "total_units": "90"

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
