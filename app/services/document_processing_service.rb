class DocumentProcessingService
  def initialize(document)
    @document = document
  end

  def process
    return unless @document.file.attached?

    @document.mark_as_processing!

    begin
      temp_file = create_temp_file

      # STEP 1: Detect buyer FIRST
      detected_buyer = BuyerDetectionService.new(temp_file.path).detect

      if detected_buyer.nil?
        raise "Unable to detect buyer type. Please ensure the document is a valid Levi Strauss or PVH Tommy Hilfiger purchase order."
      end

      # Update document with detected buyer
      @document.update!(buyer: detected_buyer, buyer_detection: "auto")
      Rails.logger.info "Detected buyer: #{detected_buyer} for document #{@document.id}"

      # STEP 2: Check if PDF should be split
      pdf_splitter = PdfSplittingService.new(temp_file.path)

      if pdf_splitter.should_split?
        Rails.logger.info "Document #{@document.id} has >10 POs, splitting into batches"
        process_with_splitting(pdf_splitter, detected_buyer)
      else
        Rails.logger.info "Document #{@document.id} has ≤10 POs, processing normally"
        process_single_pdf(temp_file.path, detected_buyer)
      end

    rescue => e
      Rails.logger.error "Failed to process document #{@document.id}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      @document.mark_as_failed!(e.message)
    ensure
      temp_file&.close
      temp_file&.unlink
    end
  end

  private

  def process_with_splitting(pdf_splitter, buyer)
    batches = pdf_splitter.split_into_batches
    all_excel_data = []
    total_pos = 0

    Rails.logger.info "Processing #{batches.length} batches for document #{@document.id} (buyer: #{buyer})"

    batches.each_with_index do |batch, index|
      Rails.logger.info "Processing batch #{index + 1}/#{batches.length} (#{batch[:po_count]} POs)"

      gemini_service = GeminiOcrService.new(batch[:file_path], buyer: buyer)
      batch_excel_data = gemini_service.extract_text

      if batch_excel_data.is_a?(Array) && batch_excel_data.any?
        all_excel_data.concat(batch_excel_data)
        total_pos += batch[:po_count]
        Rails.logger.info "Batch #{index + 1} completed: #{batch_excel_data.length} line items extracted"
      else
        Rails.logger.warn "Batch #{index + 1} returned no data"
      end

      sleep(1) if index < batches.length - 1
    end

    # Cleanup split files AFTER processing
    pdf_splitter.cleanup_split_files(batches)

    if all_excel_data.any?
      extracted_data = {
        extraction_method: "gemini_split",
        buyer: buyer,
        excel_data: all_excel_data,
        total_line_items: all_excel_data.length,
        total_pos: total_pos,
        batches_processed: batches.length,
        processed_at: Time.current
      }

      @document.mark_as_completed!(extracted_data)
      Rails.logger.info "Successfully processed document #{@document.id} with #{batches.length} batches, #{total_pos} POs, #{all_excel_data.length} line items (buyer: #{buyer})"
    else
      raise "No data extracted from any batch"
    end
  end

  def process_single_pdf(file_path, buyer)
    Rails.logger.info "Starting Gemini extraction for document #{@document.id} (buyer: #{buyer})"

    gemini_service = GeminiOcrService.new(file_path, buyer: buyer)
    excel_data = gemini_service.extract_text

    if excel_data.is_a?(Array) && excel_data.any?
      extracted_data = {
        extraction_method: "gemini",
        buyer: buyer,
        excel_data: excel_data,
        total_line_items: excel_data.length,
        processed_at: Time.current
      }

      @document.mark_as_completed!(extracted_data)
      Rails.logger.info "Successfully processed document #{@document.id} with #{excel_data.length} line items (buyer: #{buyer})"
    else
      raise "No data extracted from document"
    end
  end

  def create_temp_file
    extension = File.extname(@document.original_filename).downcase
    temp_file = Tempfile.new([ "document", extension ])

    @document.file.open do |file|
      temp_file.binmode
      temp_file.write(file.read)
    end

    temp_file.rewind
    temp_file
  end
end
