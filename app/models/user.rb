class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :lockable, :timeoutable


  has_many :accounts
  has_many :products, dependent: :destroy
  has_one :cart
  has_one :wallet, dependent: :destroy
  has_many :transactions, through: :wallet
  has_many :orders, dependent: :destroy

  # after_create :create_wallet
  #
  # def create_wallet
  #   Wallet.create(user: self, balance: 0.0)
  # end


  after_create :create_wallet_async

    def wallet
      super || create_wallet_async
    end

    private

    def create_wallet_async
      WalletCreationJob.perform_later(id)
    end

    #After job and sidekiq

end
