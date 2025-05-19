# app/controllers/payment_notifications_controller.rb
class PaymentNotificationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload = JSON.parse(request.body.read)
    transaction = Transaction.find_by(reference: payload['orderId'])

    if transaction
      transaction.update!(
        status: payload['status'] == 'SUCCESSFULL' ? :completed : :failed,
        external_reference: payload['txnid'],
        error_message: payload['message']
      )
      head :ok
    else
      head :not_found
    end
  end
end
