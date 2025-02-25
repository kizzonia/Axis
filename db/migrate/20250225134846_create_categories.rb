class CreateCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :categories do |t|
      t.string :title
      t.string :cateimg
      t.string :slug
      t.string :name
      t.string :sub_title

      t.timestamps
    end
    add_index :categories, :slug
  end
end
