class WalletsController < ApplicationController
  before_action :authenticate_user!

  def show
    @wallet = current_user.wallet
    @transactions = @wallet.transactions.order(created_at: :desc).limit(10)
  end

  def deposit
    @transaction = current_user.wallet.transactions.new(transaction_type: :deposit)
  end

  def process_deposit
    amount = params[:transaction][:amount].to_f
    phone_number = params[:transaction][:phone_number]
    payment_method = params[:transaction][:payment_method]

    if payment_method == 'orange_money'
      service = OrangeMoneyService.new(current_user)
      result = service.deposit(amount, phone_number)
    elsif payment_method == 'mtn_momo'
      service = MtnMomoService.new(current_user)
      result = service.deposit(amount, phone_number)
    else
      result = { success: false, message: 'Invalid payment method' }
    end

    if result[:success]
      redirect_to wallet_path, notice: 'Deposit was successful.'
    else
      redirect_to deposit_wallet_path, alert: result[:message]
    end
  end
end
