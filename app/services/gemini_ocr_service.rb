class GeminiOcrService
  require "base64"
  require "httparty"

  def initialize(file_path, buyer:)
    @file_path = file_path
    @buyer = buyer
  end

  def extract_text
    # Read and encode the PDF
    pdf_content = File.binread(@file_path)
    base64_content = Base64.strict_encode64(pdf_content)

    # Get buyer-specific prompt
    prompt = Buyers::BuyerFactory.prompt_for(@buyer)

    # Send to Gemini
    extracted_data = send_gemini_request(base64_content, prompt)

    # Convert to Excel format using buyer-specific mapper
    if extracted_data.is_a?(Array) && extracted_data.any?
      excel_data = convert_to_excel_format(extracted_data)

      Rails.logger.info "Gemini extracted #{extracted_data.length} POs with #{excel_data.length} total line items (buyer: #{@buyer})"
      excel_data
    else
      Rails.logger.error "Gemini extraction failed or returned no data (buyer: #{@buyer})"
      []
    end
  end

  private

  def send_gemini_request(base64_data, prompt)
    retries = 0
    max_retries = 5

    begin
      Rails.logger.info "Sending PDF to Gemini 2.5 Flash for extraction (buyer: #{@buyer})..."

      response = HTTParty.post(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=#{ENV['GOOGLE_GEMINI_API_KEY']}",
        headers: { "Content-Type" => "application/json" },
        body: {
          contents: [
            {
              parts: [
                { text: prompt },
                {
                  inlineData: {
                    mimeType: "application/pdf",
                    data: base64_data
                  }
                }
              ]
            }
          ],
          generationConfig: {
            temperature: 0.1,
            maxOutputTokens: 16384
          }
        }.to_json
      )

      if response.code == 200
        raw_response = JSON.parse(response.body).dig("candidates", 0, "content", "parts", 0, "text")

        if raw_response
          json_str = raw_response[/```json\s*(.*?)\s*```/m, 1]&.strip || raw_response.strip
          parsed_data = JSON.parse(json_str)
          Rails.logger.info "Gemini successfully extracted #{parsed_data.length} POs (buyer: #{@buyer})"
          parsed_data
        else
          Rails.logger.error "Empty response from Gemini"
          []
        end
      elsif response.code == 503
        raise StandardError.new("Service overloaded (503)")
      else
        Rails.logger.error "Gemini API failed (#{response.code}): #{response.body}"
        []
      end

    rescue JSON::ParserError => e
      Rails.logger.error "Failed to parse Gemini JSON response: #{e.message}"
      []
    rescue StandardError => e
      if e.message.include?("Service overloaded") || e.message.include?("503")
        retries += 1
        if retries <= max_retries
          Rails.logger.warn "Gemini overloaded, retrying in 5 seconds (attempt #{retries}/#{max_retries})"
          sleep(5)
          retry
        else
          Rails.logger.error "Gemini failed after #{max_retries} retries: #{e.message}"
          []
        end
      else
        Rails.logger.error "Gemini request failed: #{e.message}"
        []
      end
    rescue => e
      Rails.logger.error "Gemini request failed: #{e.message}"
      []
    end
  end

  def convert_to_excel_format(gemini_data)
    # Get buyer-specific mapper
    mapper = Buyers::BuyerFactory.mapper_for(@buyer)

    excel_rows = []

    gemini_data.each do |po|
      header = po
      line_items = po["line_items"] || []

      if line_items.empty?
        excel_rows << mapper.build_excel_row(header, {})
      else
        line_items.each do |item|
          excel_rows << mapper.build_excel_row(header, item)
        end
      end
    end

    excel_rows
  end
end
