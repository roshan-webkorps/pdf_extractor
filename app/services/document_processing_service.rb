class DocumentProcessingService
  def initialize(document)
    @document = document
  end

  def process
    return unless @document.file.attached?

    @document.mark_as_processing!

    begin
      temp_file = create_temp_file

      Rails.logger.info "Starting OCR extraction for document #{@document.id}"
      ocr_service = OcrService.new(temp_file.path)
      extracted_text = ocr_service.extract_text

      Rails.logger.info "Parsing PO data for document #{@document.id}"
      parser = PoParserService.new(extracted_text)
      parsed_pos = parser.parse

      Rails.logger.info "Mapping data to Excel format for document #{@document.id}"
      mapper = DataMappingService.new(parsed_pos)
      excel_data = mapper.map_to_excel_format

      extracted_data = {
        raw_text: extracted_text,
        parsed_pos: parsed_pos,
        excel_data: excel_data,
        total_pos: parsed_pos.length,
        total_line_items: excel_data.length,
        processed_at: Time.current
      }

      @document.mark_as_completed!(extracted_data)
      Rails.logger.info "Successfully processed document #{@document.id}"

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
      temp_file.write(file.read)
    end

    temp_file.rewind
    temp_file
  end
end
