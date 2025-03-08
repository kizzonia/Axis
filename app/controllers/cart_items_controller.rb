# app/controllers/cart_items_controller.rb
class CartItemsController < ApplicationController
  before_action :authenticate_user!

  def create
    @product = Product.find(params[:product_id])
    @cart = current_user.cart || current_user.create_cart
    @cart_item = @cart.cart_items.find_or_initialize_by(product: @product)
    @cart_item.quantity ||= 0
    @cart_item.quantity += 1

    if @cart_item.save
      redirect_back fallback_location: root_path, notice: 'Product added to cart.'
    else
      redirect_back fallback_location: root_path, alert: 'Failed to add product to cart.'
    end
  end

  def destroy
    @cart_item = CartItem.find(params[:id])
    @cart_item.destroy
    redirect_back fallback_location: root_path, notice: 'Product removed from cart.'
  end
end
