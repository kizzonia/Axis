# app/controllers/orders_controller.rb
class OrdersController < ApplicationController
  before_action :authenticate_user!

  def new
    @order = Order.new
    @cart = current_user.cart
  end

  def create
    @order = current_user.orders.build(order_params)
    @order.total_price = current_user.cart.total_price + 20 # Add shipping cost
    @order.status = :pending

    if @order.save
      current_user.cart.cart_items.each do |cart_item|
        @order.order_items.create(
          product: cart_item.product,
          quantity: cart_item.quantity,
          price: cart_item.product.price
        )
      end
      current_user.cart.destroy
      redirect_to @order, notice: 'Order placed successfully.'
    else
      render :new
    end
  end

  private

  def order_params
    params.require(:order).permit(
      :first_name, :last_name, :country, :street_address, :city, :state, :zip_code, :phone, :email, :user_id, :order_notes
    )
  end
end
