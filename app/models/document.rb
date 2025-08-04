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
    update!(status: "processing", processed_at: nil, error_message: nil)
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
end
