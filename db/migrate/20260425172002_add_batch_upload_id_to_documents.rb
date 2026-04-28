class AddBatchUploadIdToDocuments < ActiveRecord::Migration[8.0]
  def change
    add_column :documents, :batch_upload_id, :string
    add_index :documents, :batch_upload_id
  end
end
