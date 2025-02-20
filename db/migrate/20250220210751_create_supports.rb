class CreateSupports < ActiveRecord::Migration[7.2]
  def change
    create_table :supports do |t|
      t.string :title
      t.string :sub_title
      t.text :body
      t.references :help, null: false, foreign_key: true

      t.timestamps
    end
  end
end
