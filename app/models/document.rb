class Document < ApplicationRecord
  include FileValidatable

  has_one_attached :file

  STATUSES = %w[pending processing completed failed].freeze

  validates :name, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :completed, -> { where(status: "completed") }
  scope :failed, -> { where(status: "failed") }
  scope :processing, -> { where(status: "processing") }
  scope :pending, -> { where(status: "pending") }

  def pending?
    status == "pending"
  end

  def processing?
    status == "processing"
  end

  def completed?
    status == "completed"
  end

  def failed?
    status == "failed"
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

  def raw_ocr_text
    return "" unless extracted_data&.dig("raw_text")
    extracted_data["raw_text"]
  end

  def parsed_purchase_orders
    return [] unless extracted_data&.dig("parsed_pos")
    extracted_data["parsed_pos"]
  end

  def processing_summary
    return {} unless extracted_data

    {
      total_pos: total_pos_count,
      total_line_items: total_line_items_count,
      processed_at: processed_at,
      has_data: excel_data.any?
    }
  end
end
