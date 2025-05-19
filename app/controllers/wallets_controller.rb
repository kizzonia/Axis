class WalletsController < ApplicationController

      layout "accounts"
      add_flash_types :success, :danger, :info, :notice
  before_action :authenticate_user!

  def show
    @wallets = Wallet.where(user_id: current_user).order('created_at ASC')

    @wallet = current_user.wallet
    @transactions = @wallet.transactions.order(created_at: :desc).limit(10)
  end




  def process_deposit
    @transaction = current_user.wallet.transactions.new(transaction_params)

    if @transaction.save
      process_transaction
    else
      redirect_to deposit_wallet_path, alert: 'Invalid transaction parameters'
    end
  end

  private

  def process_transaction
    case @transaction.payment_method
    when 'pawapay'
      process_pawapay_deposit
    when 'orange_money', 'mtn_momo'
      process_mobile_money_deposit
    else
      handle_invalid_payment_method
    end
  end

  def process_pawapay_deposit
    service = PawapayService.new(current_user)
    response = service.create_deposit_session(@transaction)

    if response['sessionUrl']
      redirect_to response['sessionUrl'], allow_other_host: true
    else
      @transaction.update(status: :failed, error_message: response[:error])
      redirect_to deposit_wallet_path, alert: 'Failed to initialize Pawapay deposit'
    end
  end
  def   process_mobile_money_deposit
    if payment_method == 'orange_money'
      service = OrangeMoneyService.new(current_user)
      result = service.deposit(amount, phone_number)
    elsif payment_method == 'mtn_momo'
      service = MtnMomoService.new(current_user)
      result = service.deposit(amount, phone_number)
    else
      @transaction.update(status: :failed, error_message: response[:error])
      redirect_to deposit_wallet_path, alert: 'Failed to initialize  deposit'
    end
  end

  def transaction_params
    params.require(:transaction).permit(
      :amount,
      :phone_number,
      :payment_method,
      :user_id,
    ).merge(transaction_type: :deposit)
  end
end
