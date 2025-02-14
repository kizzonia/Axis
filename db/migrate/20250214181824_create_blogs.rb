class CreateBlogs < ActiveRecord::Migration[7.2]
  def change
    create_table :blogs do |t|
      t.string :title
      t.string :sub_title
      t.text :body
      t.string :blogimg
      t.string :videolink
      t.string :blogvideoimg
      t.string :slug

      t.timestamps
    end
    add_index :blogs, :slug
  end
end
