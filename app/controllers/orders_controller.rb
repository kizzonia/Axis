# app/controllers/orders_controller.rb
class OrdersController < ApplicationController
  before_action :authenticate_user!
  layout :resolve_layout
  before_action :find_order, only: [ :show, :edit, :update, :destroy, :pay_with_wallet]

  add_flash_types :success, :danger, :info, :notice


    def index
      @wallets = Wallet.where(user_id: current_user).order('created_at ASC')

      @orders_as_buyer = current_user.orders
      @orders_as_seller = Order.where(seller: current_user)
    end

    def show
      @wallets = Wallet.where(user_id: current_user).order('created_at ASC')

      @order = Order.find(params[:id])
     # Ensure the order belongs to the current user (for security)
     unless @order.user == current_user
       redirect_to root_path, alert: "You are not authorized to view this order."
     end
    end


  def new
    @order = Order.new
    @cart = current_user.cart
  end

  def create
    @cart = current_user.cart
   if @cart.nil? || @cart.cart_items.empty?
     redirect_to cart_path, alert: 'Your cart is empty.' and return
   end

   if @cart.cart_items.first.product.user.nil?
     redirect_to cart_path, alert: 'Invalid product or seller.' and return
   end

   @order = current_user.orders.build(order_params)
   @order.status = :pending
   @order.seller = @cart.cart_items.first.product.user # Assign the seller

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
  def pay_with_wallet
      if current_user.wallet.balance >= @order.total_amount
        @order.pay_with_wallet(current_user.wallet)
        redirect_to @order, notice: 'Order paid successfully with wallet balance.'
      else
        redirect_to @order, alert: 'Insufficient wallet balance.'
      end
    end

  private

  def resolve_layout
    case action_name
    when "index"
      "accounts"
    when  "show", "create", "edit"
      "application"
    else
      "application"
    end
  end

  def find_order
    @order = Order.find(params[:id])
  end
  def order_params
    params.require(:order).permit(
      :first_name, :last_name, :country, :street_address, :city, :state, :zip_code, :phone, :email, :user_id
    )
  end
end
