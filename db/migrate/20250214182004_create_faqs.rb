class CreateFaqs < ActiveRecord::Migration[7.2]
  def change
    create_table :faqs do |t|
      t.string :title
      t.string :icon
      t.string :body
      t.string :slug

      t.timestamps
    end
    add_index :faqs, :slug
  end
end
