class AddProcessedAtToTransactions < ActiveRecord::Migration[7.2]
  def change
    add_column :transactions, :processed_at, :datetime
  end
end
