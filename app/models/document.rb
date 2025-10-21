class Document < ApplicationRecord
  include FileValidatable

  has_one_attached :file

  STATUSES = %w[pending processing completed failed].freeze
  VALID_BUYERS = %w[levis pvh_tommy].freeze

  validates :name, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :buyer, inclusion: { in: VALID_BUYERS }, allow_nil: true

  scope :completed, -> { where(status: "completed") }
  scope :failed, -> { where(status: "failed") }
  scope :processing, -> { where(status: "processing") }
  scope :pending, -> { where(status: "pending") }

  def completed?
    status == "completed"
  end

  def file_size
    file.attached? ? file.byte_size : 0
  end

  def original_filename
    file.attached? ? file.filename.to_s : nil
  end

  def content_type
    file.attached? ? file.content_type : nil
  end

  def buyer_display_name
    case buyer
    when "levis"
      "Levi Strauss"
    when "pvh_tommy"
      "PVH Tommy Hilfiger"
    else
      "Unknown"
    end
  end

  def mark_as_processing!
    update!(
      status: "processing",
      processed_at: nil,
      error_message: nil,
      extracted_data: nil
    )
  end

  def mark_as_completed!(data = {})
    update!(
      status: "completed",
      processed_at: Time.current,
      extracted_data: data,
      error_message: nil
    )
  end

  def mark_as_failed!(error_msg)
    update!(
      status: "failed",
      processed_at: Time.current,
      error_message: error_msg
    )
  end

  def total_pos_count
    return 0 unless extracted_data&.dig("total_pos")
    extracted_data["total_pos"]
  end

  def total_line_items_count
    return 0 unless extracted_data&.dig("total_line_items")
    extracted_data["total_line_items"]
  end

  def excel_data
    return [] unless extracted_data&.dig("excel_data")
    extracted_data["excel_data"]
  end

  def self.export_all_summary
    completed_docs = completed.includes(:file_attachment)
    docs_with_data = completed_docs.select { |doc| doc.excel_data.present? }

    return { total_documents: 0, exportable_documents: 0 } if docs_with_data.empty?

    all_excel_data = docs_with_data.flat_map(&:excel_data)

    {
      total_documents: completed_docs.count,
      exportable_documents: docs_with_data.count,
      total_rows: all_excel_data.length,
      unique_pos: all_excel_data.map { |row| row["buyer_po_num"] }.compact.uniq.length,
      unique_buyers: all_excel_data.map { |row| row["buyer"] }.compact.uniq.length,
      total_quantity: all_excel_data.sum { |row| row["total_qty"].to_i },
      currencies: all_excel_data.map { |row| row["currency"] }.compact.uniq
    }
  end

  def export_summary
    return {} unless completed? && excel_data.present?

    {
      total_rows: excel_data.length,
      unique_pos: excel_data.map { |row| row["buyer_po_num"] }.compact.uniq.length,
      unique_buyers: excel_data.map { |row| row["buyer"] }.compact.uniq.length,
      total_quantity: excel_data.sum { |row| row["total_qty"].to_i },
      currencies: excel_data.map { |row| row["currency"] }.compact.uniq,
      has_exportable_data: excel_data.any?
    }
  end
end
