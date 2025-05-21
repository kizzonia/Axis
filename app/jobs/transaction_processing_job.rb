# # app/jobs/transaction_processing_job.rb
# class TransactionProcessingJob < ApplicationJob
#   queue_as :default
#
#   def perform(transaction_id)
#     transaction = Transaction.find(transaction_id)
#     process_transaction(transaction)
#   rescue ActiveRecord::RecordNotFound => e
#     log_error("Transaction #{transaction_id} not found: #{e.message}")
#   rescue => e
#     handle_processing_error(transaction, e.message)
#   ensure
#     notify_user(transaction) if transaction
#   end
#
#   private
#
#   def process_transaction(transaction)
#     case transaction.transaction_type
#     when 'deposit'    then process_deposit(transaction)
#     when 'withdrawal' then process_withdrawal(transaction)
#     when 'payment'    then process_payment(transaction)
#     else raise ArgumentError, "Unknown transaction type: #{transaction.transaction_type}"
#     end
#   end
#
#   def process_deposit(transaction)
#     return if transaction.completed?
#
#     if transaction.pawapay?
#       process_pawapay_deposit(transaction)
#     else
#       process_mobile_deposit(transaction)
#     end
#   end
#
#   def process_pawapay_deposit(transaction)
#     service = PawapayService.new(transaction.user)
#     response = service.create_deposit_session(
#       amount: transaction.amount,
#       currency: transaction.currency,
#       deposit_id: transaction.deposit_id,
#       phone_number: transaction.phone_number
#     )
#
#     if response[:success]
#       transaction.update!(
#         status: :pending,
#         provider_reference: response[:transaction_id]
#       )
#     else
#       transaction.mark_as_failed!(response[:error])
#     end
#   end
#
#   def process_mobile_deposit(transaction)
#     service = mobile_money_service(transaction)
#     result = service.deposit(transaction.amount, transaction.phone_number)
#
#     result[:success] ? transaction.mark_as_completed! : transaction.mark_as_failed!(result[:error])
#   end
#
#   def process_withdrawal(transaction)
#     return if insufficient_balance?(transaction)
#
#     service = mobile_money_service(transaction)
#     result = service.withdraw(transaction.amount, transaction.phone_number)
#
#     if result[:success]
#       update_wallet_balance(transaction, -transaction.amount)
#       transaction.mark_as_completed!(result.dig(:data, 'txnid'))
#     else
#       transaction.mark_as_failed!(result[:error])
#     end
#   end
#
#   def process_payment(transaction)
#     return if insufficient_balance?(transaction)
#
#     update_wallet_balance(transaction, -transaction.amount)
#     transaction.mark_as_completed!
#   end
#
#   def mobile_money_service(transaction)
#     case transaction.payment_method
#     when 'orange_money' then OrangeMoneyService.new(transaction.user)
#     when 'mtn_momo'     then MtnMomoService.new(transaction.user)
#     else raise ArgumentError, "Unsupported payment method: #{transaction.payment_method}"
#     end
#   end
#
#   def insufficient_balance?(transaction)
#     return false if transaction.wallet.balance >= transaction.amount
#     transaction.mark_as_failed!('Insufficient funds')
#     true
#   end
#
#   def update_wallet_balance(transaction, amount)
#     ActiveRecord::Base.transaction do
#       transaction.wallet.with_lock do
#         transaction.wallet.balance += amount
#         transaction.wallet.save!
#       end
#     end
#   end
#
#   def log_error(message)
#     Rails.logger.error(message)
#   end
#
#   def handle_processing_error(transaction, message)
#     log_error("Transaction processing failed: #{message}")
#     transaction&.mark_as_failed!(message)
#   end
#
#   def notify_user(transaction)
#     TransactionNotificationJob.perform_later(transaction.id)
#   end
# end
