class AddAmountsToTransactions < ActiveRecord::Migration[7.2]
  def change
    add_column :transactions, :amounts, :string
  end
end
