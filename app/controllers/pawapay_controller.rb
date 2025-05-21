class PawapayController < ApplicationController
  skip_before_action :verify_authenticity_token

  def callback
    transaction = Transaction.find_by(deposit_id: params[:depositId])

    if transaction && valid_deposit?(transaction, params)
      process_deposit(transaction, params)
      head :ok
    else
      head :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "Pawapay Callback Error: #{e.message}"
    head :unprocessable_entity
  end

  def return
    deposit_id = params[:depositId]
    transaction = Transaction.find_by(deposit_id: deposit_id)

    if transaction&.completed?
      flash[:success] = "Deposit successful!"
    elsif transaction&.failed?
      flash[:danger] = "Deposit failed: #{transaction.error_message}"
    else
      flash[:notice] = "Deposit is being processed..."
    end

    redirect_to wallet_path(current_user.wallet)
  end

  private

  def valid_deposit?(transaction, params)
    transaction.amount.to_d == params[:amount].to_d
  end

  def process_deposit(transaction, params)
    case params[:status].upcase
    when 'SUCCESS'
      handle_success(transaction, params)
    when 'FAILED'
      handle_failure(transaction, params)
    end
  end

  def handle_success(transaction, params)
    return if transaction.completed?

    ActiveRecord::Base.transaction do
      transaction.update!(
        status: :completed,
        pawapay_reference: params[:transactionId],
        processed_at: Time.current
      )
      transaction.wallet.deposit(transaction.amount)
    end
  end

  def handle_failure(transaction, params)
    transaction.update!(
      status: :failed,
      error_message: params[:failureReason] || 'Payment failed'
    )
  end
end
