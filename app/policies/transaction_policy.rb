# app/policies/transaction_policy.rb
class TransactionPolicy
  attr_reader :user, :transaction

  def initialize(user, transaction)
    @user = user
    @transaction = transaction
  end

  def show?
    transaction.wallet.user == user
  end
end
