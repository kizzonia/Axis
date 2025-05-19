# app/controllers/pawapay_controller.rb
class PawapayController < ApplicationController
  skip_before_action :verify_authenticity_token

  def callback
    transaction = Transaction.find_by(deposit_id: params[:depositId])
    if valid_callback?(transaction)
       process_callback(transaction)
       head :ok
     else
       head :unprocessable_entity
     end
   rescue => e
     Rails.logger.error "Pawapay Callback Error: #{e.message}"
     head :unprocessable_entity
   end

   private

   def valid_callback?(transaction)
     transaction.present? &&
     transaction.amount.to_d == params[:amount].to_d &&
     transaction.currency == params[:currency]
   end

   def process_callback(transaction)
     case params[:status].upcase
     when 'SUCCESS'
       handle_success(transaction)
     when 'FAILED'
       handle_failure(transaction)
     when 'CANCELLED'
       handle_cancellation(transaction)
     end
   end

   def handle_success(transaction)
     return if transaction.completed?

     ActiveRecord::Base.transaction do
       transaction.update!(
         status: :completed,
         pawapay_reference: params[:transactionId]
       )
       transaction.wallet.deposit(transaction.amount) if transaction.operation_type_deposit?
     end
   end

   def handle_failure(transaction)
     transaction.update!(
       status: :failed,
       error_message: params[:failureReason] || 'Payment failed'
     )
   end

   def handle_cancellation(transaction)
     transaction.update!(status: :cancelled)
   end
 end
