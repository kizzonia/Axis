class AddPhoneToTransactions < ActiveRecord::Migration[7.2]
  def change
    add_column :transactions, :phone_number, :string
  end
end
