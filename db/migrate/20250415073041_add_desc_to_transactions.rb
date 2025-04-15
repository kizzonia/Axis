class AddDescToTransactions < ActiveRecord::Migration[7.2]
  def change
    add_column :transactions, :description, :string
  end
end
