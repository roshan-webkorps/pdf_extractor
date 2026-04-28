class DocumentsController < ApplicationController
  include ExportErrorHandler

  before_action :set_document, only: [ :show, :update, :destroy, :download_original, :export, :retry ]

  def index
    page = params[:page].to_i
    page = 1 if page < 1
    per_page = 10

    # Start with all documents
    documents = Document.all

    # Apply status filter
    if params[:status].present?
      documents = documents.where(status: params[:status])
    end

    # Apply buyer filter
    if params[:buyer].present?
      documents = documents.where(buyer: params[:buyer])
    end

    # Apply search filter (search in name and original_filename)
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      documents = documents.where("name ILIKE ?", search_term)
    end

    # Order and paginate
    documents = documents.order(created_at: :desc)
    total_documents = documents.count
    total_pages = (total_documents.to_f / per_page).ceil

    offset = (page - 1) * per_page
    @documents = documents.limit(per_page).offset(offset)

    respond_to do |format|
      format.html
      format.json {
        render json: {
          documents: documents_json,
          pagination: {
            current_page: page,
            per_page: per_page,
            total_documents: total_documents,
            total_pages: total_pages,
            has_previous: page > 1,
            has_next: page < total_pages
          },
          export_all_summary: Document.export_all_summary
        }
      }
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

  def batch
    files = params[:files]

    if files.blank?
      return render json: { error: "No files provided" }, status: :unprocessable_entity
    end

    if files.length > 5
      return render json: { error: "Maximum 5 files per upload batch" }, status: :unprocessable_entity
    end

    batch_upload_id = SecureRandom.uuid
    created = []
    errors  = []

    files.each do |file|
      doc = Document.new(
        name:            File.basename(file.original_filename, ".*"),
        file:            file,
        batch_upload_id: batch_upload_id
      )

      if doc.save
        DocumentProcessingJob.perform_later(doc.id)
        created << document_json(doc)
      else
        errors << { filename: file.original_filename, errors: doc.errors.full_messages }
      end
    end

    render json: {
      message:         "#{created.length} file(s) uploaded and queued for processing",
      batch_upload_id: batch_upload_id,
      documents:       created,
      errors:          errors
    }, status: :created
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

  def retry
    @document.update(status: :pending, error_message: nil, is_retry: true)
    DocumentProcessingJob.perform_later(@document.id)

    render json: {
      message: "Document queued for reprocessing",
      document: document_json(@document)
    }
  end

  def export_selected
    document_ids = params[:document_ids] || []

    if document_ids.empty?
      return render json: { error: "No documents selected" }, status: :unprocessable_entity
    end

    documents = Document.where(id: document_ids, status: :completed)
    documents_with_data = documents.select { |doc| doc.excel_data.present? }

    if documents_with_data.empty?
      return render json: { error: "No exportable data in selected documents" }, status: :unprocessable_entity
    end

    begin
      excel_service = ExcelExportService.new(documents_with_data)
      package = excel_service.generate

      send_data package.to_stream.read,
                type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                filename: "StandardSalesOrder.xlsx",
                disposition: "attachment"

    rescue => e
      handle_export_error(e, "Export selected documents")
    end
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

      send_data package.to_stream.read,
                type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                filename: "StandardSalesOrder.xlsx",
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

      send_data package.to_stream.read,
                type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                filename: "StandardSalesOrder.xlsx",
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

  def document_json(document)
    base_data = {
      id: document.id,
      name: document.name,
      status: document.status,
      buyer: document.buyer,
      buyer_display_name: document.buyer_display_name,
      buyer_detection: document.buyer_detection,
      file_size: document.file_size,
      original_filename: document.original_filename,
      content_type: document.content_type,
      created_at: document.created_at,
      updated_at: document.updated_at,
      processed_at: document.processed_at,
      error_message: document.error_message,
      total_pos: document.total_pos_count,
      total_line_items: document.total_line_items_count,
      page_count: document.page_count,
      batch_upload_id: document.batch_upload_id
    }

    if document.completed?
      base_data[:export_summary] = document.export_summary
      base_data[:excel_data] = document.excel_data
    end

    base_data
  end

end
