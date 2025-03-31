class Order < ApplicationRecord
  belongs_to :user # Buyer
   belongs_to :seller, class_name: 'User' # Seller
   has_many :order_items
   has_many :products, through: :order_items

   enum status: { pending: 'pending', paid: 'paid', shipped: 'shipped', completed: 'completed', cancelled: 'cancelled' }


   has_many :transactions, as: :transactionable


 validates :total_amount, numericality: { greater_than: 0 }

 def pay_with_wallet(wallet)
   wallet.withdraw(total_amount)
   transactions.create!(
     amount: total_amount,
     transaction_type: :payment,
     status: :completed,
     payment_method: :wallet
   )
   update!(status: :paid)
 end

 
end
