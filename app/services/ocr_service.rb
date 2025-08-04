class OcrService
  include RTesseract

  def initialize(file_path)
    @file_path = file_path
    @extracted_text = ""
  end

  def extract_text
    case File.extname(@file_path).downcase
    when ".pdf"
      extract_from_pdf
    when ".jpg", ".jpeg", ".png"
      extract_from_image
    else
      raise "Unsupported file format"
    end

    @extracted_text
  end

  private

  def extract_from_pdf
    pdf_to_images.each_with_index do |image_path, index|
      puts "Processing page #{index + 1}..."
      page_text = RTesseract.new(image_path, lang: "eng").to_s
      @extracted_text += "\n--- PAGE #{index + 1} ---\n#{page_text}\n"

      File.delete(image_path) if File.exist?(image_path)
    end
  end

  def extract_from_image
    @extracted_text = RTesseract.new(@file_path, lang: "eng").to_s
  end

  def pdf_to_images
    image_paths = []

    image = MiniMagick::Image.open(@file_path)

    if image.pages.any?
      image.pages.each_with_index do |page, index|
        temp_path = Rails.root.join("tmp", "page_#{SecureRandom.hex(8)}_#{index}.png")
        page.format("png")
        page.write(temp_path)
        image_paths << temp_path.to_s
      end
    else
      temp_path = Rails.root.join("tmp", "single_page_#{SecureRandom.hex(8)}.png")
      image.format("png")
      image.write(temp_path)
      image_paths << temp_path.to_s
    end

    image_paths
  rescue => e
    Rails.logger.error "PDF to image conversion failed: #{e.message}"
    raise "Failed to convert PDF to images: #{e.message}"
  end
end
