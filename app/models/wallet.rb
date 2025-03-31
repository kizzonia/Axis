class Wallet < ApplicationRecord
  belongs_to :user
    has_many :transactions, dependent: :destroy

    validates :balance, numericality: { greater_than_or_equal_to: 0 }

    def deposit(amount)
      update!(balance: balance + amount)
    end

    def withdraw(amount)
      update!(balance: balance - amount)
    end
end
