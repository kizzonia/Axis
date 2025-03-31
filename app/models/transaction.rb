class Transaction < ApplicationRecord
  belongs_to :wallet
  # belongs_to :user

  enum transaction_type: { deposit: 'deposit', withdrawal: 'withdrawal', payment: 'payment' }
 enum status: { pending: 'pending', completed: 'completed', failed: 'failed' }
 enum payment_method: { orange_money: 'orange_money', mtn_momo: 'mtn_momo', wallet: 'wallet' }

 validates :amount, numericality: { greater_than: 0 }
 validates :transaction_type, presence: true
 validates :status, presence: true

 before_create :generate_reference

 private

 def generate_reference
   self.reference ||= SecureRandom.hex(10)
 end

end
