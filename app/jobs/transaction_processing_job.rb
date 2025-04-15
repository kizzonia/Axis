# app/jobs/transaction_processing_job.rb
class TransactionProcessingJob < ApplicationJob
  queue_as :default

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
    transaction&.mark_as_failed!(e.message)
  end

  private

  def process_deposit(transaction)
    service = OrangeMoneyService.new(transaction.user)
    result = service.deposit(transaction.amount, transaction.phone_number)

    if result[:success]
      transaction.mark_as_completed!(result.dig(:data, 'txnid'))
    else
      transaction.mark_as_failed!(result[:error])
    end
  end

  def process_withdrawal(transaction)
    if transaction.wallet.balance < transaction.amount
      return transaction.mark_as_failed!('Insufficient funds')
    end

    service = OrangeMoneyService.new(transaction.user)
    result = service.withdraw(transaction.amount, transaction.phone_number)

    if result[:success]
      ActiveRecord::Base.transaction do
        transaction.wallet.with_lock do
          transaction.wallet.balance -= transaction.amount
          transaction.wallet.save!
          transaction.mark_as_completed!(result.dig(:data, 'txnid'))
        end
      end
    else
      transaction.mark_as_failed!(result[:error])
    end
  end

  def process_payment(transaction)
    if transaction.wallet.balance < transaction.amount
      return transaction.mark_as_failed!('Insufficient funds')
    end

    ActiveRecord::Base.transaction do
      transaction.wallet.with_lock do
        transaction.wallet.balance -= transaction.amount
        transaction.wallet.save!
        transaction.mark_as_completed!
      end
    end
  end
end
