# app/jobs/transaction_processing_job.rb
class TransactionProcessingJob < ApplicationJob
  queue_as :default
  # retry_on StandardError, wait: :exponentially_longer, attempts: 1

  def perform(transaction_id)
    transaction = Transaction.find(transaction_id)

    case transaction.transaction_type
    when 'deposit'
      process_deposit(transaction)
    when 'withdrawal'
      process_withdrawal(transaction)
    when 'payment'
      process_payment(transaction)
    else
      raise ArgumentError, "Unknown transaction type: #{transaction.transaction_type}"
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "Transaction #{transaction_id} not found: #{e.message}"
  rescue => e
    Rails.logger.error "Transaction processing failed: #{e.message}"
    # raise  # Will trigger the retry mechanism
  end

  private

  def process_deposit(transaction)
    service = OrangeMoneyService.new(transaction.user)
    result = service.deposit(transaction.amount, transaction.phone_number)

    unless result[:success]
      raise "Deposit failed: #{result[:error]}"
    end
  end

  # ... similar methods for withdrawal and payment ...
end
