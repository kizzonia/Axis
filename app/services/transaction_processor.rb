# # app/services/transaction_processor.rb
# class TransactionProcessor
#   def initialize(transaction)
#     @transaction = transaction
#     @user = transaction.wallet.user
#   end
#
#   def process
#     case @transaction.transaction_type
#     when 'deposit'
#       process_deposit
#     when 'withdrawal'
#       process_withdrawal
#     when 'payment'
#       process_payment
#     else
#       raise ArgumentError, "Unknown transaction type: #{@transaction.transaction_type}"
#     end
#   end
#
#   private
#
#   def process_deposit
#     if @transaction.pawapay?
#       process_pawapay_deposit
#     else
#       process_mobile_deposit
#     end
#   end
#
#   def process_pawapay_deposit
#     service = PawapayService.new(@user)
#     response = service.create_deposit_session(
#       @transaction.amount,
#       @transaction.currency,
#       @transaction.deposit_id,
#       @transaction.phone_number
#     )
#
#     if response[:success]
#       @transaction.update!(
#         status: :pending,
#         provider_reference: response[:transaction_id]
#       )
#     else
#       @transaction.mark_as_failed!(response[:error])
#     end
#   end
#
#   def process_mobile_deposit
#     service = mobile_money_service
#     result = service.deposit(
#       @transaction.amount,
#       @transaction.phone_number
#     )
#
#     result[:success] ? @transaction.mark_as_completed! : @transaction.mark_as_failed!(result[:error])
#   end
#
#   def process_withdrawal
#     validate_balance
#     service = mobile_money_service
#     result = service.withdraw(
#       @transaction.amount,
#       @transaction.phone_number
#     )
#
#     if result[:success]
#       ActiveRecord::Base.transaction do
#         @user.wallet.withdraw(@transaction.amount)
#         @transaction.mark_as_completed!
#       end
#     else
#       @transaction.mark_as_failed!(result[:error])
#     end
#   end
#
#   def process_payment
#     validate_balance
#     ActiveRecord::Base.transaction do
#       @user.wallet.withdraw(@transaction.amount)
#       @transaction.mark_as_completed!
#     end
#   end
#
#   def mobile_money_service
#     case @transaction.payment_method
#     when 'orange_money' then OrangeMoneyService.new(@user)
#     when 'mtn_momo'     then MtnMomoService.new(@user)
#     else raise ArgumentError, "Unsupported payment method: #{@transaction.payment_method}"
#     end
#   end
#
#   def validate_balance
#     return if @user.wallet.balance >= @transaction.amount
#     @transaction.mark_as_failed!("Insufficient funds")
#     raise "Insufficient balance for transaction #{@transaction.id}"
#   end
# end
