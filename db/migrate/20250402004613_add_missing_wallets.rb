# db/migrate/[timestamp]_add_missing_wallets.rb
class AddMissingWallets < ActiveRecord::Migration[7.2]
  def up
    User.left_outer_joins(:wallet).where(wallets: { id: nil }).find_each do |user|
      Wallet.create!(user: user, balance: 0.0)
      puts "Created wallet for user #{user.email}"
    end
  end

  def down
    # No need to reverse this
  end
end
