class AddValuesToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :sku, :string
    add_column :products, :state, :string
    add_column :products, :status, :boolean
    add_column :products, :discounttype, :string
  end
end
