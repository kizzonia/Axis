# app/jobs/transaction_notification_job.rb
class TransactionNotificationJob < ApplicationJob
  queue_as :notifications
  retry_on StandardError, wait: 5.minutes, attempts: 3

  def perform(transaction_id)
    transaction = Transaction.find(transaction_id)
    user = transaction.wallet.user

    case transaction.transaction_type
    when 'deposit'
      TransactionMailer.deposit_completed(user, transaction).deliver_now
    when 'withdrawal'
      TransactionMailer.withdrawal_completed(user, transaction).deliver_now
    when 'payment'
      TransactionMailer.payment_completed(user, transaction).deliver_now
    end
  end
end
