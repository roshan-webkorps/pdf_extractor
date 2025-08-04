class PoParserService
  def initialize(ocr_text)
    @text = ocr_text
    @purchase_orders = []
  end

  def parse
    detect_purchase_orders
    @purchase_orders.map { |po_text| extract_po_data(po_text) }
  end

  private

  def detect_purchase_orders
    po_indicators = [
      /Purchase Order#?\s*\d+/i,
      /PO NUMBER\s*\d+/i,
      /P\.?O\.?\s*#?\s*\d+/i
    ]

    po_positions = []
    po_indicators.each do |pattern|
      @text.scan(pattern) do |match|
        pos = Regexp.last_match.offset(0)[0]
        po_positions << pos
      end
    end

    po_positions.sort!

    if po_positions.empty?
      @purchase_orders = [ @text ]
    else
      po_positions.each_with_index do |start_pos, index|
        end_pos = po_positions[index + 1] || @text.length
        po_text = @text[start_pos...end_pos]
        @purchase_orders << po_text
      end
    end
  end

  def extract_po_data(po_text)
    {
      header_data: extract_header_data(po_text),
      line_items: extract_line_items(po_text)
    }
  end

  def extract_header_data(text)
    header = {}

    header_patterns = {
      purchase_order_number: [ /Purchase Order#?\s*([A-Z0-9]+)/i, /PO NUMBER\s*([A-Z0-9]+)/i ],
      season: [ /Season\s*(?:Code)?\s*(\d+)/i, /SEASON CODE\s*(\d+)/i ],
      currency: [ /Currency\s*([A-Z]{3})/i, /PO Currency\s*([A-Z]{3})/i ],
      doc_date: [ /DocDate\s*([\d\/\-\.]+)/i, /PO Release Date\s*([\d\/\-\.]+)/i ],
      total_po_value: [ /Total PO Value\s*([\d,\.]+)/i, /PO Value\s*([\d,\.]+)/i ],
      total_po_quantity: [ /Total PO Quantity\s*([\d,]+)/i, /PO Quantity\s*([\d,]+)/i ],
      ffc_code: [ /FFC Code\s*([A-Z0-9]+)/i ],
      ffc_description: [ /FFC Description\s*([^\n\r]+)/i ],
      manufacturer: [ /Manufacturer\s*(\d+)/i ],
      company_code: [ /Company Code\s*(\d+)/i ],
      division: [ /Division\s*([^\n\r]+)/i ],
      sourcing_region: [ /Sourcing Region\s*([A-Z]+)/i, /SOURCING REGION\s*([A-Z]+)/i ],
      branch_office: [ /Branch Office\s*([A-Z]+)/i, /BRANCH OFFICE\s*([A-Z]+)/i ],
      inco_terms: [ /Inco Terms\s*([A-Z]+)/i, /INCO TERMS\s*([A-Z]+)/i ],
      payment_terms: [ /Payment Terms\s*([^\n\r]+)/i ]
    }

    header_patterns.each do |key, patterns|
      patterns.each do |pattern|
        match = text.match(pattern)
        if match
          header[key] = match[1].strip
          break
        end
      end
    end

    header[:invoice_to] = extract_address(text, /Invoice To\s*(.*?)(?=\n\n|\nSeller|\nManufacturer|$)/mi)
    header[:delivery_address] = extract_address(text, /Delivery Address\s*(.*?)(?=\n\n|\nPlant|\nTotal|$)/mi)

    header
  end

  def extract_address(text, pattern)
    match = text.match(pattern)
    return nil unless match

    address_text = match[1].strip
    lines = address_text.split(/\n/).map(&:strip).reject(&:empty?)

    country = extract_country_from_address(lines)

    {
      full_address: lines.join(", "),
      country: country,
      lines: lines
    }
  end

  def extract_country_from_address(lines)
    country_patterns = [
      /\b(USA|United States|America)\b/i,
      /\b(India|INDIA)\b/i,
      /\b(China|CHINA)\b/i,
      /\b(Singapore|SINGAPORE)\b/i,
      /\b(Korea|KOREA)\b/i,
      /\b(Thailand|THAILAND)\b/i,
      /\b(Malaysia|MALAYSIA)\b/i,
      /\b(Philippines|PHILIPPINES)\b/i,
      /\b(Germany|GERMANY)\b/i,
      /\b(Brazil|BRASIL)\b/i,
      /\b(Chile|CHILE)\b/i,
      /\b(Mexico|MEXICO)\b/i,
      /\b(Mauritius|MAURITIUS)\b/i,
      /\b(Hong Kong|HONG KONG)\b/i
    ]

    lines.each do |line|
      country_patterns.each do |pattern|
        match = line.match(pattern)
        return match[1].capitalize if match
      end
    end

    last_line = lines.last
    return last_line if last_line && last_line.length < 20 && last_line.match?(/^[A-Za-z\s]+$/)

    nil
  end

  def extract_line_items(text)
    line_items = []

    material_pattern = /(\w+[-]\d+)\s+([^\n\r]+?)\s+(\w+)\s+(\d+)\s+([\d\.]+)\s+([\d\.]+)/

    text.scan(material_pattern) do |match|
      material_code, description, size, quantity, unit_price, total_value = match

      line_items << {
        material_code: material_code,
        description: description.strip,
        size: size,
        quantity: quantity.to_i,
        unit_price: unit_price.to_f,
        total_value: total_value.to_f
      }
    end

    size_pattern = /(\w+)\s+(\d+)\s+([\d\.\/\-]+)/

    if line_items.empty?
      current_material = extract_current_material(text)

      text.scan(size_pattern) do |match|
        size, quantity, date = match

        next if date.length > 10 || quantity.to_i == 0

        line_items << {
          material_code: current_material,
          description: extract_material_description(text, current_material),
          size: size,
          quantity: quantity.to_i,
          unit_price: extract_unit_price(text),
          total_value: quantity.to_i * extract_unit_price(text)
        }
      end
    end

    line_items
  end

  def extract_current_material(text)
    material_patterns = [
      /Material\s+([A-Z0-9\-]+)/i,
      /Generic Material\s+([A-Z0-9\-]+)/i,
      /Product\s+([A-Z0-9\-]+)/i
    ]

    material_patterns.each do |pattern|
      match = text.match(pattern)
      return match[1] if match
    end

    "UNKNOWN"
  end

  def extract_material_description(text, material_code)
    pattern = /#{Regexp.escape(material_code)}\s+([^\n\r]+)/i
    match = text.match(pattern)
    match ? match[1].strip : "Material Description"
  end

  def extract_unit_price(text)
    price_patterns = [
      /PO Unit Price\s+([\d\.]+)/i,
      /Unit Price\s+([\d\.]+)/i,
      /Price\s+([\d\.]+)/i
    ]

    price_patterns.each do |pattern|
      match = text.match(pattern)
      return match[1].to_f if match
    end

    1.0
  end
end
