class WalletsController < ApplicationController
  layout "accounts"
  before_action :authenticate_user!

  def show
    @wallet = current_user.wallet
    @wallets = Wallet.where(user_id: current_user).order('created_at ASC')

    @transactions = @wallet.transactions.order(created_at: :desc).limit(10)
  end

  def deposit
    @wallet = current_user.wallet
    @transaction = @wallet.transactions.new
    @transaction.deposit_id ||= SecureRandom.uuid
  end

  def process_deposit
    @wallet = current_user.wallet
    @transaction = @wallet.transactions.new(transaction_params)

    # Ensure deposit_id is always present
    @transaction.deposit_id ||= SecureRandom.uuid

    if @transaction.save
      pawapay_response = PawapayService.new(current_user).create_deposit_session(@transaction)

      if pawapay_response[:success] && pawapay_response[:session_url].present?
        # Redirect to Pawapay session page
        redirect_to pawapay_response[:session_url], allow_other_host: true
      else
        flash[:danger] = pawapay_response[:error] || "Failed to create deposit session"
        redirect_to deposit_wallet_path
      end
    else
      flash[:danger] = @transaction.errors.full_messages.to_sentence
      redirect_to deposit_wallet_path
    end
  end

  private

  def transaction_params
    params.require(:transaction).permit(
      :amount,
      :phone_number,
      :payment_method,
      :currency,
      :deposit_id
    ).merge(transaction_type: :deposit)

  end

  def wallet_params
    params.require(:transaction).permit(
      :balance,
      :user_id
    )

  end
end
