module Buyers
  module Asos
    class Prompt
      def self.build
        <<~PROMPT
          You are an expert at extracting structured data from Purchase Order PDFs. Extract ALL Purchase Orders from this document.

          **CRITICAL INSTRUCTIONS:**
          1. Split documents by PO Number - each unique PO Number is a separate Purchase Order
          2. For each PO, extract ONLY the fields listed below - set fields to empty string if not found
          3. Create one row per line item (size/quantity combination)
          4. DO NOT use default values unless I explicitly specify them
          5. READ CAREFULLY - extract the EXACT field specified, from the EXACT location specified

          **EXTRACT THESE FIELDS PER PO:**

          **Header Fields (same for all line items in a PO):**
          - "po_number": Extract from "PO Number" field at the top of the document
          - "currency": Extract from "Payment Currency" field (e.g., USD, EUR, etc.)
          - "payment_terms": Extract from "Payment Terms" field (e.g., 45 Days from invoice 5%)
          - "date_issued": Extract from "Date Issued" field. Convert format from DD/MM/YYYY to DD.MM.YYYY (e.g., "05/06/2025" becomes "05.06.2025")
          - "delivery_method": Extract from "Delivery Method" field (e.g., Sea, Land etc)
          - "handover_window_date": Extract from "Handover Window Start Date" field. Convert format from DD/MM/YYYY to DD.MM.YYYY (e.g., "05/06/2025" becomes "05.06.2025"
          - "oc_delivery_date": Look for the "Handover Window Start Date" field and subtract 7 days from that date. Eg: if the Handover Window Start Date is 2/3/2026 then the value becomes 23.02.2026. Make sure take into account the number of days in that month.
          - "first_destination": Extract ONLY the country name from "First Destination" (e.g., United Kingdom, Germany etc)
          - "po_total": Look for the "PO Total" label in the file and extract the value right next to that label (e.g., 350, 650 etc)
          - "po_total": Locate the text label "PO Total" and extract the small numeric value that appears immediately to the right or directly beside it (e.g., 350, 650 etc.). Ignore currency or monetary totals such as 4,511.00 or larger multi-digit formatted numbers with commas or decimals.
          - "shipping_terms": Extract from "Shipping Terms" field (e.g., FOB)

          **Line Item Fields (per size/quantity row):**
          - "final_destination": Extract from "Final Destination" field (e.g., FC01 Barnsley)
          - "supplier_ref": Extract from "Supplier Ref." field (e.g., SS MURCIA)
          - "packing_method": Extract from "Packing Method" field (e.g., FLAT)
          - "website_colour": Extract from "Website Colour" field (e.g., BLUE, BLACK etc)
          - "brand_size": Extract from "Brand Size" field (e.g., M, L, XL etc)
          - "quantity": Extract from "Qty" field (e.g., 195, 111 etc)
          - "unit_cost": Extract from "PO Unit Cost" field (e.g., 6.99, 9.66 etc)

          **IMPORTANT FOR SIZE EXTRACTION:**
          - Each Line# has a size breakdown table with columns: XS, S, M, L, XL, XXL, etc.
          - Each column with a quantity should be a separate line item
          - All line items from the same Line# table share the same style, color description, and total_units

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
