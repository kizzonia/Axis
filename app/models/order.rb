class Order < ApplicationRecord
  belongs_to :user # Buyer
   belongs_to :seller, class_name: 'User' # Seller
   has_many :order_items
   has_many :products, through: :order_items

   enum status: { pending: 'pending', paid: 'paid', shipped: 'shipped', completed: 'completed', cancelled: 'cancelled' }
end
