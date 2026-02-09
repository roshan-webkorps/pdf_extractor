class OcrAuditLog < ApplicationRecord
  validates :page_count, presence: true, numericality: { greater_than: 0 }
  validates :operation_type, presence: true, inclusion: { in: %w[initial_scan retry] }

  scope :for_month, ->(year, month) {
    start_date = Date.new(year, month, 1).beginning_of_day
    end_date = start_date.end_of_month.end_of_day
    where(created_at: start_date..end_date)
  }

  scope :initial_scans, -> { where(operation_type: "initial_scan") }
  scope :retries, -> { where(operation_type: "retry") }

  def self.total_pages_for_month(year, month)
    for_month(year, month).sum(:page_count)
  end

  def self.monthly_breakdown(year, month)
    logs = for_month(year, month)
    {
      total_pages: logs.sum(:page_count),
      initial_scans: logs.initial_scans.sum(:page_count),
      retries: logs.retries.sum(:page_count),
      total_operations: logs.count
    }
  end
end
