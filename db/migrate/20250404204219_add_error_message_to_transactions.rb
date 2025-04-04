class AddErrorMessageToTransactions < ActiveRecord::Migration[7.2]
  def change
    add_column :transactions, :error_message, :string
  end
end
