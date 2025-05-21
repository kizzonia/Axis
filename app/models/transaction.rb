# app/models/transaction.rb
class Transaction < ApplicationRecord
  belongs_to :wallet
  belongs_to :user
  belongs_to :transactionable, polymorphic: true, optional: true
  belongs_to :order, optional: true

  # Validations
  validates :amount
  validates :phone_number, presence: true

  # Enums

    enum transaction_type: { deposit: 'deposit', withdrawal: 'withdrawal', payment: 'payment' }
    enum status: { pending: 'pending', completed: 'completed', failed: 'failed' }

    before_create :generate_deposit_id

    # Add this enum if not already present
    # enum payment_method: { orange_money: 0, mtn_momo: 1, pawapay: 2 }
    enum payment_method: {
      orange_money: 'orange_money',
      mtn_momo: 'mtn_momo',
      pawapay: 'pawapay',
      wallet: 'wallet'
    }, _prefix: true


  # Callbacks
  before_create :generate_reference
  after_commit :process_async, on: :create

  # # Scopes
  # scope :orange_money_transactions, -> { where(payment_method: :orange_money) }
  # scope :recent, -> { order(created_at: :desc) }

  # def process_async
  #   TransactionProcessingJob.perform_later(id)
  # end

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
end
