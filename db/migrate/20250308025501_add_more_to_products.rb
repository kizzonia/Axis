class AddMoreToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :slug, :string
    add_index :products, :slug
    add_column :products, :overview, :text
    add_column :products, :verified, :boolean
  end
end
