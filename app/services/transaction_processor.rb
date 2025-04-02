# app/services/transaction_processor.rb
class TransactionProcessor
  def initialize(transaction)
    @transaction = transaction
    @user = transaction.wallet.user
  end

  def process
    case @transaction.transaction_type
    when 'deposit'
      process_deposit
    when 'withdrawal'
      process_withdrawal
    when 'payment'
      process_payment
    else
      raise "Unknown transaction type: #{@transaction.transaction_type}"
    end
  end

  private

  def process_deposit
    service = payment_service
    result = service.deposit(@transaction.amount, @transaction.phone_number)

    if result[:success]
      complete_transaction
    else
      fail_transaction(result[:error])
    end
  end

  def process_withdrawal
    service = payment_service
    result = service.withdraw(@transaction.amount, @transaction.phone_number)

    if result[:success]
      complete_transaction
    else
      fail_transaction(result[:error])
    end
  end

  def process_payment
    if @user.wallet.balance >= @transaction.amount
      @user.wallet.withdraw(@transaction.amount)
      complete_transaction
    else
      fail_transaction("Insufficient funds")
    end
  end

  def payment_service
    case @transaction.payment_method
    when 'orange_money' then OrangeMoneyService.new(@user)
    when 'mtn_momo' then MtnMomoService.new(@user)
    else raise "Unknown payment method: #{@transaction.payment_method}"
    end
  end

  def complete_transaction
    @transaction.update!(status: :completed)
    TransactionNotificationJob.perform_later(@transaction.id)
  end

  def fail_transaction(error)
    @transaction.update!(status: :failed, error_message: error)
    TransactionNotificationJob.perform_later(@transaction.id)
  end
end
