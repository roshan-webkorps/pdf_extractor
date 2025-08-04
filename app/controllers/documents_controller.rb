class DocumentsController < ApplicationController
  before_action :set_document, only: [ :show, :update, :destroy, :download_original, :export ]

  def index
    @documents = Document.order(created_at: :desc)

    respond_to do |format|
      format.html
      format.json { render json: documents_json }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: document_json(@document) }
    end
  end

  def create
    @document = Document.new(document_params)

    if @document.save
      DocumentProcessingJob.perform_later(@document.id)

      render json: {
        message: "File uploaded successfully and processing started",
        document: document_json(@document)
      }, status: :created
    else
      render json: {
        errors: @document.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    if @document.update(update_params)
      render json: {
        message: "Document updated successfully",
        document: document_json(@document)
      }
    else
      render json: {
        errors: @document.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @document.file.purge if @document.file.attached?
    @document.destroy

    render json: { message: "Document deleted successfully" }
  end

  def download_original
    unless @document.file.attached?
      return render json: { error: "No file attached" }, status: :not_found
    end

    redirect_to rails_blob_path(@document.file, disposition: "attachment")
  end

  def export
    unless @document.completed?
      return render json: { error: "Document processing not completed" }, status: :unprocessable_entity
    end

    unless @document.excel_data.present?
      return render json: { error: "No data available for export" }, status: :unprocessable_entity
    end

    begin
      excel_service = ExcelExportService.new([ @document ])
      package = excel_service.generate

      filename = "#{sanitize_filename(@document.name)}_export_#{Time.current.strftime('%Y%m%d_%H%M%S')}.xlsx"

      send_data package.to_stream.read,
                type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                filename: filename,
                disposition: "attachment"

    rescue => e
      handle_export_error(e, "Individual document export")
    end
  end

  def export_all
    completed_documents = Document.completed.includes(:file_attachment)

    if completed_documents.empty?
      return render json: { error: "No completed documents available for export" }, status: :unprocessable_entity
    end

    documents_with_data = completed_documents.select { |doc| doc.excel_data.present? }

    if documents_with_data.empty?
      return render json: { error: "No documents contain exportable data" }, status: :unprocessable_entity
    end

    begin
      excel_service = ExcelExportService.new(documents_with_data)
      package = excel_service.generate

      filename = "all_purchase_orders_export_#{Time.current.strftime('%Y%m%d_%H%M%S')}_#{documents_with_data.count}_docs.xlsx"

      send_data package.to_stream.read,
                type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                filename: filename,
                disposition: "attachment"

    rescue => e
      handle_export_error(e, "Export all documents")
    end
  end

  def export_all_summary
    summary = Document.export_all_summary
    render json: summary
  end

  private

  def set_document
    @document = Document.find(params[:id])
  end

  def document_params
    params.require(:document).permit(:name, :file)
  end

  def update_params
    params.require(:document).permit(:name)
  end

  def documents_json
    @documents.map { |doc| document_json(doc) }
  end

  def sanitize_filename(filename)
    filename.gsub(/[^\w\s_-]+/, "_").gsub(/\s+/, "_").strip
  end

  def document_json(document)
    base_data = {
      id: document.id,
      name: document.name,
      status: document.status,
      file_size: document.file_size,
      original_filename: document.original_filename,
      content_type: document.content_type,
      created_at: document.created_at,
      updated_at: document.updated_at,
      processed_at: document.processed_at,
      error_message: document.error_message,
      total_pos: document.total_pos_count,
      total_line_items: document.total_line_items_count
    }

    if document.completed?
      base_data[:export_summary] = document.export_summary
    end

    base_data
  end

  def documents_json
    documents_data = @documents.map { |doc| document_json(doc) }

    {
      documents: documents_data,
      export_all_summary: Document.export_all_summary
    }
  end
end
