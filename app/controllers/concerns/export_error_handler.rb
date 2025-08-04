module ExportErrorHandler
  extend ActiveSupport::Concern

  private

  def handle_export_error(error, context = "Export")
    Rails.logger.error "#{context} failed: #{error.message}"
    Rails.logger.error error.backtrace.join("\n")

    render json: {
      error: "#{context} failed. Please try again.",
      details: Rails.env.development? ? error.message : nil
    }, status: :internal_server_error
  end
end
