class BuyerDetectionService
  DETECTION_PATTERNS = {
    "levis" => [
      /LEVIS/i,
      /LEVI\s+STRAUSS/i
    ],
    "pvh_tommy" => [
      /PVH/i,
      /TOMMY\s+HILFIGER/i
    ]
  }.freeze

  def initialize(file_path)
    @file_path = file_path
  end

  def detect
    text = extract_first_pages

    return nil if text.blank?

    DETECTION_PATTERNS.each do |buyer, patterns|
      patterns.each do |pattern|
        if text.match?(pattern)
          Rails.logger.info "Detected buyer '#{buyer}' using pattern: #{pattern.inspect}"
          return buyer
        end
      end
    end

    Rails.logger.warn "Could not detect buyer from document"
    nil
  rescue => e
    Rails.logger.error "Buyer detection failed: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    nil
  end

  private

  def extract_first_pages
    reader = PDF::Reader.new(@file_path)

    pages_to_scan = [ reader.pages[0], reader.pages[1] ].compact

    if pages_to_scan.empty?
      Rails.logger.error "PDF has no readable pages"
      return ""
    end

    text = pages_to_scan.map(&:text).join("\n")

    Rails.logger.debug "Extracted #{text.length} characters from first #{pages_to_scan.length} pages"

    text
  rescue => e
    Rails.logger.error "Failed to extract text for buyer detection: #{e.message}"
    ""
  end
end
