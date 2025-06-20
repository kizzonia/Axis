class AddTotalAmountToOrders < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :total_amount, :decimal
  end
end
