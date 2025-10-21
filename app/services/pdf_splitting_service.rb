require "pdf-reader"
require "combine_pdf"
require "set"

class PdfSplittingService
  BATCH_SIZE = 5
  PO_THRESHOLD = 5

  def initialize(file_path)
    @file_path = file_path
    @reader = PDF::Reader.new(@file_path)
  end

  def should_split?
    po_locations = find_po_locations
    po_locations.length > PO_THRESHOLD
  end

  def split_into_batches
    po_locations = find_po_locations

    Rails.logger.info "Found #{po_locations.length} POs in PDF"

    return [ { file_path: @file_path, po_count: po_locations.length, tempfiles: [] } ] if po_locations.length <= PO_THRESHOLD

    batches = []
    po_locations.each_slice(BATCH_SIZE).with_index do |po_batch, batch_index|
      start_page = po_batch.first[:page]
      end_page = po_batch.last[:end_page] || po_batch.last[:page]

      split_result = create_split_pdf(start_page, end_page, batch_index)

      batches << {
        file_path: split_result[:path],
        po_count: po_batch.length,
        batch_index: batch_index,
        po_numbers: po_batch.map { |po| po[:po_number] }.compact,
        tempfiles: [ split_result[:tempfile] ]  # Keep reference to prevent GC
      }
    end

    batches
  end

  def cleanup_split_files(batches)
    batches.each do |batch|
      if batch[:tempfiles]
        batch[:tempfiles].each do |tempfile|
          tempfile.close
          tempfile.unlink
        end
      end
    end
  end

  private

  def find_po_locations
    po_locations = []
    seen_pos = Set.new

    @reader.pages.each_with_index do |page, page_index|
      page_number = page_index + 1
      text = page.text

      # Look for both PO number patterns:
      # 1. "PO NUMBER 1000606063" or "PO NUMBER T530038084"
      # 2. "Purchase Order# 2500043993" or "Purchase Order# T530038084"
      # 3. "PO Number: 4500622115" or "PO Number: T530038084"
      po_number = nil

      # Try pattern 1: PO NUMBER followed by value (numeric or alphanumeric)
      po_number_match = text.match(/PO NUMBER\s+([A-Z]?\d+)/i)
      if po_number_match
        po_number = po_number_match[1]
      else
        # Try pattern 2: Purchase Order# followed by value (numeric or alphanumeric)
        purchase_order_match = text.match(/Purchase Order#?\s*([A-Z]?\d+)/i)
        if purchase_order_match
          po_number = purchase_order_match[1]
        else
          # Try pattern 3: PO Number: followed by value (numeric or alphanumeric)
          po_number_colon_match = text.match(/PO Number:\s*([A-Z]?\d+)/i)
          if po_number_colon_match
            po_number = po_number_colon_match[1]
          end
        end
      end

      if po_number
        # Only add if we haven't seen this PO before (avoid duplicates)
        unless seen_pos.include?(po_number)
          po_locations << {
            po_number: po_number,
            page: page_number,
            end_page: nil
          }
          seen_pos.add(po_number)
        end
      end
    end

    # Calculate end pages for each PO
    po_locations.each_with_index do |po, index|
      if index < po_locations.length - 1
        po[:end_page] = po_locations[index + 1][:page] - 1
      else
        po[:end_page] = @reader.page_count
      end
    end

    Rails.logger.info "Final PO locations found: #{po_locations.length}"

    po_locations
  end

  def create_split_pdf(start_page, end_page, batch_index)
    begin
      new_pdf = CombinePDF.new
      source_pdf = CombinePDF.load(@file_path)

      (start_page - 1..end_page - 1).each do |page_index|
        if page_index < source_pdf.pages.length
          new_pdf << source_pdf.pages[page_index]
        end
      end

      # Create temporary file but DON'T close it yet
      temp_file = Tempfile.new([ "split_pdf_batch_#{batch_index}", ".pdf" ])
      new_pdf.save(temp_file.path)
      temp_file.flush  # Ensure data is written

      Rails.logger.info "Created batch #{batch_index + 1}: pages #{start_page}-#{end_page}"

      # Return both the path and the tempfile object
      { path: temp_file.path, tempfile: temp_file }
    rescue => e
      Rails.logger.error "Failed to create split PDF for batch #{batch_index}: #{e.message}"
      raise e
    end
  end
end
