# app/controllers/pawapay_controller.rb
class PawapayController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:callback]
  before_action :authenticate_user!, except: [:callback]

  # Called from JS via fetch() to securely create a session with Pawapay
  def create_session
    deposit_id = params[:deposit_id]
    amount = params[:amount]
    msisdn = params[:msisdn]

    return render json: { error: "Missing parameters" }, status: :unprocessable_entity unless deposit_id && amount && msisdn

    payload = {
      depositId: deposit_id,
      returnUrl: pawapay_return_url_url + "?depositId=#{deposit_id}",
      statementDescription: "Wallet deposit",
      amount: amount.to_s,
      msisdn: msisdn,
      language: "EN",
      country: "CMR",
      reason: "Wallet funding",
      metadata: [
        { fieldName: "userId", fieldValue: current_user.id.to_s },
        { fieldName: "depositId", fieldValue: deposit_id }
      ]
    }

    response = HTTParty.post("https://api.pawapay.io/v1/widget/sessions",
      headers: {
        "Authorization" => "Bearer #{ENV['PAWAPAY_SECRET_KEY']}",
        "Content-Type" => "application/json"
      },
      body: payload.to_json
    )

    if response.success? && response.parsed_response["sessionUrl"]
      render json: { session_url: response.parsed_response["sessionUrl"] }
    else
      render json: { error: response.parsed_response["message"] || "Failed to create session" }, status: :bad_request
    end
  end

  # Called from Pawapay server after payment completes
  def callback
    transaction = Transaction.find_by(deposit_id: params[:depositId])

    if transaction && valid_deposit?(transaction, params)
      process_deposit(transaction, params)
      head :ok
    else
      head :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "Pawapay Callback Error: #{e.message}"
    head :unprocessable_entity
  end

  # Redirected here after deposit completes
  def return
    deposit_id = params[:depositId]
    transaction = Transaction.find_by(deposit_id: deposit_id)

    if transaction&.completed?
      flash[:success] = "Deposit successful!"
    elsif transaction&.failed?
      flash[:danger] = "Deposit failed: #{transaction.error_message}"
    else
      flash[:notice] = "Deposit is being processed..."
    end

    redirect_to wallet_path(current_user.wallet)
  end

  private

  def valid_deposit?(transaction, params)
    transaction.amount.to_d == params[:amount].to_d
  end

  def process_deposit(transaction, params)
    case params[:status].upcase
    when 'SUCCESS'
      handle_success(transaction, params)
    when 'FAILED'
      handle_failure(transaction, params)
    end
  end

  def handle_success(transaction, params)
    return if transaction.completed?

    ActiveRecord::Base.transaction do
      transaction.update!(
        status: :completed,
        pawapay_reference: params[:transactionId],
        processed_at: Time.current
      )
      transaction.wallet.deposit(transaction.amount)
    end
  end

  def handle_failure(transaction, params)
    transaction.update!(
      status: :failed,
      error_message: params[:failureReason] || 'Payment failed'
    )
  end
end
