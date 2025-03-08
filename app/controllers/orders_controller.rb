# app/controllers/orders_controller.rb
class OrdersController < ApplicationController
  before_action :authenticate_user!

  def new
    @cart = current_user.cart
    @order = Order.new
  end

  def create
    @cart = current_user.cart
    @order = current_user.orders.build(total_price: @cart.total_price, status: 'pending')

    if @order.save
      @cart.cart_items.each do |cart_item|
        @order.order_items.create(
          product: cart_item.product,
          quantity: cart_item.quantity,
          price: cart_item.product.price
        )
      end
      @cart.destroy
      redirect_to @order, notice: 'Order placed successfully.'
    else
      render :new
    end
  end
end
