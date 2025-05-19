class AddDepositIdToTransactions < ActiveRecord::Migration[7.2]
  def change
    add_column :transactions, :deposit_id, :string
    add_column :transactions, :pawapay_reference, :string
    add_column :transactions, :merchant_reference, :string 
    add_column :transactions, :operation_type, :integer
    add_column :transactions, :currency, :string

  end
end
