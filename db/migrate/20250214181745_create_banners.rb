class CreateBanners < ActiveRecord::Migration[7.2]
  def change
    create_table :banners do |t|
      t.string :title
      t.string :sub_title
      t.string :bannerimg
      t.string :slug

      t.timestamps
    end
    add_index :banners, :slug
  end
end
