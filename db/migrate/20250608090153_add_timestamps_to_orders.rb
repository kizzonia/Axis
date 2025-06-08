class AddTimestampsToOrders < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :paid_at, :datetime
    add_column :orders, :shipped_at, :datetime
    add_column :orders, :completed_at, :datetime
  end
end
