class AddValuesToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :balance, :string
    add_column :users, :status, :boolean
    add_column :users, :verified, :boolean
    add_column :users, :body, :text
  end
end
