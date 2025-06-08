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
     @cart  = current_user.cart
     if @cart.nil? || @cart.cart_items.empty?
       return redirect_to cart_path, alert: 'Your cart is empty.'
     end

     seller = @cart.cart_items.first.product.user
     @order = current_user.orders.build(order_params.merge(
       status:      :pending,
       seller:      seller,
       total_amount: @cart.total_amount
     ))

     if @order.save
       @cart.cart_items.each do |item|
         @order.order_items.create!(
           product:  item.product,
           quantity: item.quantity,
           price:    item.product.price
         )
       end
       @cart.destroy
       redirect_to @order, notice: 'Order placed successfully.'
     else
       render :new
     end
   end

   # POST /orders/:id/pay_escrow
   def pay_escrow
     authorize_buyer!(@order)
     if current_user.wallet.balance < @order.total_amount
       return redirect_to @order, alert: 'Insufficient wallet balance.'
     end

     @order.hold_in_escrow!(current_user.wallet)
     redirect_to @order, success: 'Payment held in escrow. Awaiting shipment.'
   rescue => e
     redirect_to @order, danger: "Payment failed: #{e.message}"
   end

   # POST /orders/:id/upload_shipment
   def upload_shipment
     authorize_seller!(@order)
     unless params[:order] && params[:order][:shipment_proof]
       return redirect_to @order, alert: 'Please attach a shipment proof file.'
     end

     @order.shipment_proof.attach(params[:order][:shipment_proof])
     @order.mark_shipped!
     redirect_to @order, success: 'Shipment proof uploaded.'
   rescue => e
     redirect_to @order, danger: "Upload failed: #{e.message}"
   end

   # POST /orders/:id/release_escrow
   def release_escrow
     authorize_buyer!(@order)
     @order.release_escrow!
     redirect_to @order, success: 'Funds released to seller.'
   rescue => e
     redirect_to @order, danger: "Release failed: #{e.message}"
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
