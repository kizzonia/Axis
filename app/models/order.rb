# app/models/order.rb
class Order < ApplicationRecord
  belongs_to :user                 # buyer
  belongs_to :seller, class_name: 'User'
  has_many   :order_items, dependent: :destroy
  has_many   :products, through: :order_items

  # CarrierWave mount for shipment proof file
  mount_uploader :shipment_proof, ShipmentProofUploader

  # Escrow-related timestamps (ensure these columns exist via migration):
  #   paid_at      :datetime
  #   shipped_at   :datetime
  #   completed_at :datetime

  enum status: {
    pending:   'pending',    # awaiting payment
    paid:      'paid',       # buyer has paid, funds held
    shipped:   'shipped',    # seller uploaded proof
    completed: 'completed',  # buyer released funds to seller
    cancelled: 'cancelled'   # refunded or voided
  }

  has_many :transactions, as: :transactionable, dependent: :destroy

  validates :total_amount, numericality: { greater_than: 0 }

  #
  # 1) Buyer pays → hold funds in escrow
  #
  def hold_in_escrow!(buyer_wallet)
    raise "Order already paid" unless pending?
    raise "Insufficient wallet balance" if buyer_wallet.balance < total_amount

    ActiveRecord::Base.transaction do
      # Deduct from buyer
      buyer_wallet.with_lock do
        buyer_wallet.balance -= total_amount
        buyer_wallet.save!
      end

      # Record escrow_hold transaction
      transactions.create!(
        amount:           total_amount,
        transaction_type: :escrow_hold,
        status:           :held,
        payment_method:   :wallet,
        user:             user
      )

      # Mark order paid
      update!(
        status:   :paid,
        paid_at:  Time.current
      )
    end
  end

  #
  # 2) Seller uploads shipment proof → mark shipped
  #
  def mark_shipped!
    raise "Order not paid" unless paid?
    raise "Already marked shipped" if shipped?

    update!(
      status:     :shipped,
      shipped_at: Time.current
    )
  end

  #
  # 3) Buyer releases escrow → credit seller, complete order
  #
  def release_escrow!
    raise "Order not shipped" unless shipped?
    raise "Already completed"    if completed?

    seller_wallet = seller.wallet || seller.create_wallet!(balance: 0.0)

    ActiveRecord::Base.transaction do
      # Credit seller
      seller_wallet.with_lock do
        seller_wallet.balance += total_amount
        seller_wallet.save!
      end

      # Record escrow_release transaction
      seller_wallet.transactions.create!(
        amount:           total_amount,
        transaction_type: :escrow_release,
        status:           :success,
        payment_method:   :wallet,
        transactionable:  self,
        user:             seller
      )

      # Update original hold transaction to released
      transactions.find_by(transaction_type: :escrow_hold)&.update!(status: :released)

      # Complete order
      update!(
        status:       :completed,
        completed_at: Time.current
      )
    end
  end
end
