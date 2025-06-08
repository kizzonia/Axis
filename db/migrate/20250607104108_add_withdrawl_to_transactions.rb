class AddWithdrawlToTransactions < ActiveRecord::Migration[7.2]
  def change
    add_column :transactions, :withdrawal_id, :string
  end
end
