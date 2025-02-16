class CreateAccounts < ActiveRecord::Migration[7.2]
  def change
    create_table :accounts do |t|
      t.string :balance
      t.string :slug
      t.string :revenue
      t.boolean :status
      t.boolean :verify
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :accounts, :slug
  end
end
