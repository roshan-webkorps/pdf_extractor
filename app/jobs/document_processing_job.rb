class DocumentProcessingJob < ApplicationJob
  queue_as :default

  retry_on StandardError, attempts: 3

  def perform(document_id)
    document = Document.find(document_id)

    Rails.logger.info "Processing document #{document_id}"

    DocumentProcessingService.new(document).process

    Rails.logger.info "Completed processing document #{document_id}"

  rescue => e
    Rails.logger.error "Failed to process document #{document_id}: #{e.message}"

    document = Document.find(document_id)
    document.mark_as_failed!(e.message) unless document.completed?

    raise e
  end
end
