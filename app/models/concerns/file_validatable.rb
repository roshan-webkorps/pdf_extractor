module FileValidatable
  extend ActiveSupport::Concern

  included do
    validate :acceptable_file
  end

  private

  def acceptable_file
    return unless file.attached?

    unless file.content_type.in?([ "application/pdf", "image/jpeg", "image/png", "image/jpg" ])
      errors.add(:file, "must be a PDF or image file (JPEG, PNG)")
    end

    if file.byte_size > 10.megabytes
      errors.add(:file, "must be less than 10MB")
    end
  end
end
