class AddIconimgToCategories < ActiveRecord::Migration[7.2]
  def change
    add_column :categories, :iconimg, :string
  end
end
