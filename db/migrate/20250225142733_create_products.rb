class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.string :name
      t.string :title
      t.text :description
      t.decimal :price
      t.string :prodimage
      t.string :status
      t.references :category, null: false, foreign_key: true
      t.references :sub_category, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
