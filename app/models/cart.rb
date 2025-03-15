class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items, dependent: :destroy # Add this line
 has_many :products, through: :cart_items



   # Calculate the total price of all items in the cart
   def total_price
     cart_items.sum { |cart_item| cart_item.quantity * cart_item.product.price }
   end

end
