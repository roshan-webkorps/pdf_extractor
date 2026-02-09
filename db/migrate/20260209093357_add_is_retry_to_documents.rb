class AddIsRetryToDocuments < ActiveRecord::Migration[8.0]
  def change
    add_column :documents, :is_retry, :boolean, default: false, null: false
  end
end
