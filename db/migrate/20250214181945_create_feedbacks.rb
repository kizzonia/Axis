class CreateFeedbacks < ActiveRecord::Migration[7.2]
  def change
    create_table :feedbacks do |t|
      t.string :title
      t.string :icon
      t.string :body
      t.string :slug

      t.timestamps
    end
    add_index :feedbacks, :slug
  end
end
