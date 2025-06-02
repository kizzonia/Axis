# app/controllers/pawapay_controller.rb
class PawapayController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:callback]
  before_action        :authenticate_user!, except: [:callback]

  # POST /pawapay/callback
  def callback
    deposit_id  = params["depositId"]
    transaction = Transaction.find_by(deposit_id: deposit_id)

    if transaction.nil?
      Rails.logger.warn "Pawapay Callback: Unknown deposit_id=#{deposit_id}"
      return head :not_found
    end

    unless valid_deposit?(transaction, params)
      returned = params["requestedAmount"].presence || params["depositedAmount"]
      Rails.logger.warn "Pawapay Callback: Amount mismatch for deposit_id=#{deposit_id}. "\
                        "Expected #{transaction.amounts}, got #{returned}"
      return head :unprocessable_entity
    end

    process_deposit(transaction, params)
    head :ok

  rescue => e
    Rails.logger.error "Pawapay Callback Error: #{e.message}\n#{e.backtrace.first}"
    head :internal_server_error
  end

  # GET /pawapay/return?depositId=...
  def return
    deposit_id  = params["depositId"]
    transaction = Transaction.find_by(deposit_id: deposit_id)

    if transaction&.completed?
      flash[:success] = "Deposit successful!"
    elsif transaction&.failed?
      flash[:danger] = "Deposit failed: #{transaction.error_message || 'Unknown error'}"
    else
      flash[:notice] = "Deposit is being processed. Please wait a moment."
    end

    redirect_to wallet_path(current_user.wallet)
  end

  private

  # Compare stored string `amounts` to incoming string "requestedAmount" (or fallback to "depositedAmount")
  def valid_deposit?(transaction, params)
    returned_amount_str = params["requestedAmount"].presence || params["depositedAmount"]
    return false if returned_amount_str.blank?

    transaction.amounts.to_d == returned_amount_str.to_d
  rescue
    false
  end

  # Dispatch based on Pawapay’s returned status
  def process_deposit(transaction, params)
    status = params["status"]&.upcase

    case status
    when 'COMPLETED', 'SUCCESS'
      handle_success(transaction, params)
    when 'FAILED'
      handle_failure(transaction, params)
    else
      Rails.logger.warn "Pawapay Callback: Unrecognized status='#{status}' for deposit_id=#{params["depositId"]}"
    end
  end

  def handle_success(transaction, params)
    return if transaction.completed?

    ActiveRecord::Base.transaction do
      transaction.update!(
        status:            :completed,
        pawapay_reference: params["transactionId"] || params["paymentReference"],
        processed_at:      Time.current
      )

      # Convert string to decimal before depositing
      amount_decimal = transaction.amounts.to_d
      transaction.wallet.deposit(amount_decimal)

      TransactionNotificationJob.perform_later(transaction.id)
      Rails.logger.info "Pawapay: deposit_id=#{transaction.deposit_id} completed; " \
                        "credited #{amount_decimal} XAF to wallet #{transaction.wallet_id}"
    end
  end

  def handle_failure(transaction, params)
    return if transaction.failed?

    transaction.update!(
      status:        :failed,
      error_message: params["failureReason"] || 'Pawapay reported failure'
    )
    TransactionNotificationJob.perform_later(transaction.id)

    Rails.logger.info "Pawapay: deposit_id=#{transaction.deposit_id} failed; " \
                      "reason=#{transaction.error_message}"
  end
end
