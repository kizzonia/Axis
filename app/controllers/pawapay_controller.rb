# app/controllers/pawapay_controller.rb
class PawapayController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:callback]
  before_action :authenticate_user!, except: [:callback]

  # Called from Pawapay server after payment completes
  def callback
    deposit_id = params[:depositId]
    transaction = Transaction.find_by(deposit_id: deposit_id)

    if transaction.nil?
      Rails.logger.warn "Pawapay Callback: Unknown deposit ID #{deposit_id}"
      return head :not_found
    end

    unless valid_deposit?(transaction, params)
      Rails.logger.warn "Pawapay Callback: Invalid amount for deposit #{deposit_id}"
      return head :unprocessable_entity
    end

    process_deposit(transaction, params)
    head :ok

  rescue => e
    Rails.logger.error "Pawapay Callback Error: #{e.message} — #{e.backtrace.first}"
    head :internal_server_error
  end

  # Redirected here after deposit completes
  def return
    deposit_id = params[:depositId]
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

  # Compare returned amount to the stored `amounts`
  def valid_deposit?(tx, params)
    tx.amounts == params[:amounts]
  rescue
    false
  end

  def process_deposit(transaction, params)
    case params[:status]&.upcase
    when 'SUCCESS' then handle_success(transaction, params)
    when 'FAILED'  then handle_failure(transaction, params)
    else
      Rails.logger.warn "Pawapay Callback: Unknown status #{params[:status]}"
    end
  end

  def handle_success(transaction, params)
    return if transaction.completed?

    ActiveRecord::Base.transaction do
      transaction.update!(
        status:            :completed,
        pawapay_reference: params[:transactionId],
        processed_at:      Time.current
      )
      transaction.wallet.deposit(transaction.amounts)
      Rails.logger.info "Wallet #{transaction.wallet.id} credited with #{transaction.amounts} XAF"
      TransactionNotificationJob.perform_later(transaction.id)
    end
  end

  def handle_failure(transaction, params)
    return if transaction.failed?

    transaction.update!(
      status:        :failed,
      error_message: params[:failureReason] || 'Pawapay reported failure'
    )
    Rails.logger.info "Transaction #{transaction.deposit_id} marked as failed: #{transaction.error_message}"
    TransactionNotificationJob.perform_later(transaction.id)
  end
end
