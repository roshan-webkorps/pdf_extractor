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

    # This will be implemented in Phase 4
    render json: { message: "Individual export - coming in Phase 4" }
  end

  def export_all
    # This will be implemented in Phase 4
    render json: { message: "Export all - coming in Phase 4" }
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
    {
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
  end
end
