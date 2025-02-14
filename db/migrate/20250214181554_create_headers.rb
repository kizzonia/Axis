class CreateHeaders < ActiveRecord::Migration[7.2]
  def change
    create_table :headers do |t|
      t.string :abouts_title
      t.string :abouts_sub_title
      t.string :services_title
      t.string :services_sub_title
      t.string :boards_title
      t.string :boards_sub_title
      t.string :features_title
      t.string :features_sub_title
      t.string :feedbacks_title
      t.string :feedbacks_sub_title
      t.string :blogs_title
      t.string :blogs_sub_title
      t.string :cta1
      t.string :cta2
      t.string :headerimg
      t.string :products_title
      t.string :products_sub_title

      t.timestamps
    end
  end
end
