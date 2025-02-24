class AddValuesToAccounts < ActiveRecord::Migration[7.2]
  def change
    add_column :accounts, :city, :string
    add_column :accounts, :state, :string
    add_column :accounts, :zipcode, :string
    add_column :accounts, :phone, :string
    add_column :accounts, :username, :string
  end
end
