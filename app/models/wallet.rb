class Wallet < ApplicationRecord
  belongs_to :user
    has_many :transactions, dependent: :destroy

    validates :balance, numericality: { greater_than_or_equal_to: 0 }

    def deposit(amount_decimal)
    update!(balance: balance + amount_decimal)
  end

    def withdraw(amounts)
      update!(balance: balance - amounts)
    end
end
