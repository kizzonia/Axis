class Transaction < ApplicationRecord
  belongs_to :wallet
  belongs_to :user
  belongs_to :transactionable, polymorphic: true, optional: true
  belongs_to :order, optional: true


  # Enums
  enum transaction_type: {
    deposit: 'deposit',
    withdrawal: 'withdrawal',
    payment: 'payment'
  }

  enum status: {
    pending: 'pending',
    completed: 'completed',
    failed: 'failed'
  }

  enum payment_method: {
    pawapay: 'pawapay',
    wallet: 'wallet'
  }, _prefix: true

  # Callbacks
  before_create :generate_deposit_id
  # before_create :generate_reference
  after_commit :process_async, on: :create

  # Methods
  def mark_as_failed!(error_message)
    update!(status: :failed, error_message: error_message)
    TransactionNotificationJob.perform_later(id)
  end

  def mark_as_completed!(external_reference = nil)
    update!(
      status: :completed,
      processed_at: Time.current,
      external_reference: external_reference
    )
    TransactionNotificationJob.perform_later(id)
  end

  private

  def generate_deposit_id
    self.deposit_id ||= SecureRandom.uuid if deposit?
  end

  def generate_reference
    self.reference ||= SecureRandom.alphanumeric(10).upcase
  end

  def process_async
    # Activate if you want to process transactions via background job
    # TransactionProcessingJob.perform_later(id)
  end
end
