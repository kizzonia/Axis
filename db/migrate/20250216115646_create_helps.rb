class CreateHelps < ActiveRecord::Migration[7.2]
  def change
    create_table :helps do |t|
      t.string :title
      t.string :sub_title
      t.string :body
      t.string :slug

      t.timestamps
    end
    add_index :helps, :slug
  end
end
