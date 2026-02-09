class CreateOcrAuditLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :ocr_audit_logs do |t|
      t.integer :document_id
      t.integer :page_count, null: false
      t.string :operation_type, null: false
      t.string :buyer

      t.timestamps
    end

    add_index :ocr_audit_logs, :document_id
    add_index :ocr_audit_logs, :created_at
    add_index :ocr_audit_logs, :operation_type
  end
end
