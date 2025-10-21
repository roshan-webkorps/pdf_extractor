class AddBuyerFieldsToDocuments < ActiveRecord::Migration[8.0]
  def change
    add_column :documents, :buyer, :string
    add_column :documents, :buyer_detection, :string, default: 'auto'

    add_index :documents, :buyer
  end
end
