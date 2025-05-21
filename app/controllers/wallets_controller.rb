# app/controllers/wallets_controller.rb
class WalletsController < ApplicationController
  layout "accounts"
  before_action :authenticate_user!

  def show
    @wallet      = current_user.wallet
    @transactions = @wallet.transactions.order(created_at: :desc).limit(10)
  end

  def deposit
    @wallet      = current_user.wallet
    @transaction = @wallet.transactions.new
    # Pre‑assign a deposit_id so you can use it in a hidden field if you like
    @transaction.deposit_id ||= SecureRandom.uuid
  end

  def process_deposit
    @wallet      = current_user.wallet
    @transaction = @wallet.transactions.new(transaction_params)

    # Guarantee we have a deposit_id
    @transaction.deposit_id ||= SecureRandom.uuid

    if @transaction.save
      service  = PawapayService.new(current_user)
      response = service.create_deposit_session(@transaction)

      if response["sessionUrl"].present?
        # Redirect into Pawapay’s hosted payment page
        redirect_to response["sessionUrl"], allow_other_host: true
      else
        # Bubble up API error
        flash[:danger] = response[:error] || "Unable to create payment session"
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
  :currency,           # <-- Add this
  :deposit_id          # <-- And this
).merge(transaction_type: :deposit)
  end
end
