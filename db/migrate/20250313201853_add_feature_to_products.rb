class AddFeatureToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :feature, :boolean
  end
end
