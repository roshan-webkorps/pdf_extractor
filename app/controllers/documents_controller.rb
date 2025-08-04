# app/controllers/documents_controller.rb
class DocumentsController < ApplicationController
  before_action :set_document, only: [ :show, :update, :destroy ]

  # GET /documents
  def index
    @documents = Document.order(created_at: :desc)

    respond_to do |format|
      format.html
      format.json { render json: documents_json }
    end
  end

  # GET /documents/:id
  def show
    respond_to do |format|
      format.html
      format.json { render json: document_json(@document) }
    end
  end

  # POST /documents
  def create
    @document = Document.new(document_params)

    if @document.save
      # TODO: Enqueue background job in Phase 3
      render json: {
        message: "File uploaded successfully",
        document: document_json(@document)
      }, status: :created
    else
      render json: {
        errors: @document.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # PUT /documents/:id
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

  # DELETE /documents/:id
  def destroy
    @document.file.purge if @document.file.attached?
    @document.destroy

    render json: { message: "Document deleted successfully" }
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
      error_message: document.error_message
    }
  end
end
