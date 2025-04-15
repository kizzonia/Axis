# app/jobs/transaction_notification_job.rb
class TransactionNotificationJob < ApplicationJob
  queue_as :notifications

  def perform(transaction_id)
    transaction = Transaction.find_by(id: transaction_id)
    return unless transaction

    user = transaction.user

    case transaction.transaction_type
    when 'deposit'
      TransactionMailer.deposit_completed(user, transaction).deliver_now
    when 'withdrawal'
      TransactionMailer.withdrawal_completed(user, transaction).deliver_now
    when 'payment'
      TransactionMailer.payment_completed(user, transaction).deliver_now
    end
  rescue => e
    Rails.logger.error "Notification failed for transaction #{transaction_id}: #{e.message}"
  end
end
