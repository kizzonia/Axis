class AddValuesToOrders < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :first_name, :string
    add_column :orders, :last_name, :string
    add_column :orders, :state, :string
    add_column :orders, :city, :string
    add_column :orders, :country, :string
    add_column :orders, :street_address, :string
    add_column :orders, :phone, :string
    add_column :orders, :email, :string
    add_column :orders, :zip_code, :string
    add_column :orders, :order_note, :string
  end
end
