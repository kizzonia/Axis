# lib/tasks/wallet.rake
# rails wallet:create_missing
namespace :wallet do
  desc "Create wallets for users who don't have one"
  task create_missing: :environment do
    users_without_wallets = User.left_outer_joins(:wallet).where(wallets: { id: nil })

    if users_without_wallets.any?
      puts "Creating wallets for #{users_without_wallets.count} users..."

      users_without_wallets.find_each do |user|
        wallet = Wallet.create(user: user, balance: 0.0)
        WalletMailer.wallet_created(user, wallet).deliver_later
        puts "Created wallet for #{user.email}"
      end

      puts "Completed wallet creation process."
    else
      puts "All users already have wallets."
    end
  end
end
