# app/models/order.rb
class Order < ApplicationRecord
  belongs_to :user # Buyer
  belongs_to :seller, class_name: 'User' # Seller
  has_many :order_items
  has_many :products, through: :order_items

  enum status: { pending: 'pending', paid: 'paid', shipped: 'shipped', completed: 'completed', cancelled: 'cancelled' }
  has_many :transactions, as: :transactionable

  validates :total_amount, numericality: { greater_than: 0 }

  def pay_with_wallet(buyer_wallet)
    ActiveRecord::Base.transaction do
      # Withdraw from buyer
      buyer_wallet.with_lock do
        raise 'Insufficient funds' if buyer_wallet.balance < total_amount
        buyer_wallet.balance -= total_amount
        buyer_wallet.save!
      end

      # Deposit to seller
      seller_wallet = seller.wallet || seller.create_wallet!(balance: 0.0)
      seller_wallet.with_lock do
        seller_wallet.balance += total_amount
        seller_wallet.save!
      end

      # Create transactions
      transactions.create!(
        amount: -total_amount,
        transaction_type: :payment,
        status: :completed,
        payment_method: :wallet,
        user: user
      )

      seller.transactions.create!(
        amount: total_amount,
        transaction_type: :payment,
        status: :completed,
        payment_method: :wallet,
        order: self,
        user: seller
      )

      update!(status: :paid)

      OrderNotificationJob.perform_later(id)

    end
  rescue => e
    errors.add(:base, e.message)
    raise ActiveRecord::Rollback
  end
end
