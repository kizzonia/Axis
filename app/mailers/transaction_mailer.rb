class TransactionMailer < ApplicationMailer
  def deposit_completed(user, transaction)
    @user = user
    @transaction = transaction
    mail(to: @user.email, subject: 'Deposit Completed')
  end

  def payment_completed(user, transaction)
    @user = user
    @transaction = transaction
    mail(to: @user.email, subject: 'Payment Completed')
  end

  def withdrawal_completed(user, transaction)
    @user = user
    @transaction = transaction
    mail(to: @user.email, subject: 'Withdrawal Completed')
  end
end
