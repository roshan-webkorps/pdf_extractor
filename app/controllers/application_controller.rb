class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  protect_from_forgery with: :exception

  skip_before_action :verify_authenticity_token, if: -> { request.format.json? }

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :parameter_missing

  private

  def record_not_found
    respond_to do |format|
      format.html { redirect_to root_path, alert: "Document not found" }
      format.json { render json: { error: "Document not found" }, status: :not_found }
    end
  end

  def parameter_missing(exception)
    respond_to do |format|
      format.html { redirect_to root_path, alert: "Invalid request" }
      format.json { render json: { error: exception.message }, status: :bad_request }
    end
  end
end
