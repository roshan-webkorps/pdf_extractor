class DocumentProcessingService
  def initialize(document)
    @document = document
  end

  def process
    return unless @document.file.attached?

    @document.mark_as_processing!

    begin
      temp_file = create_temp_file

      Rails.logger.info "Starting Gemini extraction for document #{@document.id}"
      gemini_service = GeminiOcrService.new(temp_file.path)
      excel_data = gemini_service.extract_text

      if excel_data.is_a?(Array) && excel_data.any?
        extracted_data = {
          extraction_method: "gemini",
          excel_data: excel_data,
          total_line_items: excel_data.length,
          processed_at: Time.current
        }

        @document.mark_as_completed!(extracted_data)
        Rails.logger.info "Successfully processed document #{@document.id} with #{excel_data.length} line items"
      else
        raise "No data extracted from document"
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
