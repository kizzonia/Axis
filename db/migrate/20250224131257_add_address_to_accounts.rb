class AddAddressToAccounts < ActiveRecord::Migration[7.2]
  def change
    add_column :accounts, :address, :string
  end
end
