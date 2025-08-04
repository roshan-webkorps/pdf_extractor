class CreateDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :documents do |t|
      t.string :name, null: false
      t.string :status, default: 'pending', null: false
      t.json :extracted_data
      t.text :error_message
      t.datetime :processed_at

      t.timestamps
    end

    add_index :documents, :status
    add_index :documents, :created_at
  end
end
