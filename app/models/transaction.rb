# app/models/transaction.rb
class Transaction < ApplicationRecord
  belongs_to :wallet
  belongs_to :user
  belongs_to :transactionable, polymorphic: true, optional: true

  validates :user, presence: true
  validates :wallet, presence: true

  enum transaction_type: { deposit: 'deposit', withdrawal: 'withdrawal', payment: 'payment' }
  enum status: { pending: 'pending', completed: 'completed', failed: 'failed' }
  enum payment_method: { orange_money: 'orange_money', mtn_momo: 'mtn_momo', wallet: 'wallet' }

  validates :amount, numericality: { greater_than: 0 }
  validates :transaction_type, :status, presence: true

  before_create :generate_reference
  after_commit :process_async, on: :create

  def process_async
    TransactionProcessingJob.set(wait: 5.seconds).perform_later(id)
  end


   def mark_as_failed!(error_message)
     update!(status: :failed, error_message: error_message)
   end
  private

  def generate_reference
    self.reference ||= SecureRandom.hex(10)
  end
end
