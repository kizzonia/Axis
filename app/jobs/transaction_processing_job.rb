# app/jobs/transaction_processing_job.rb
class TransactionProcessingJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: 5.seconds, attempts: 3

  def perform(transaction_id)
    transaction = Transaction.find(transaction_id)
    processor = TransactionProcessor.new(transaction)
    processor.process
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "TransactionProcessingJob: Transaction #{transaction_id} not found - #{e.message}"
  end
end
