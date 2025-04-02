# app/jobs/wallet_creation_job.rb
class WalletCreationJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    return if user.wallet.present?

    wallet = Wallet.create!(user: user, balance: 0.0)
    WalletMailer.wallet_created(user, wallet).deliver_now
  end
end
