class AddPageCountToDocuments < ActiveRecord::Migration[8.0]
  def change
    add_column :documents, :page_count, :integer
  end
end
