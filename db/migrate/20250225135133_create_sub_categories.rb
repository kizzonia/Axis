class CreateSubCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :sub_categories do |t|
      t.string :name
      t.references :category, null: false, foreign_key: true
      t.string :title
      t.string :slug

      t.timestamps
    end
    add_index :sub_categories, :slug
  end
end
