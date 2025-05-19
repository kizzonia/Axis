# app/services/pawapay_service.rb
class PawapayService
  BASE_URL = 'https://api.pawapay.io/v1'.freeze

  def initialize(user)
    @user = user
    @merchant_id = ENV['PAWAPAY_MERCHANT_ID']
    @secret_key = ENV['PAWAPAY_SECRET_KEY']
  end

  def create_deposit_session(transaction)
    endpoint = "#{BASE_URL}/widget/sessions"

    payload = {
      depositId: transaction.deposit_id,
      returnUrl: Rails.application.routes.url_helpers.pawapay_callback_url(host: ENV['APP_HOST']),
      statementDescription: "Wallet deposit #{@user.id}",
      amount: transaction.amount.to_s,
      msisdn: transaction.phone_number,
      language: 'EN',
      # country: 'ZMB', # Update based on user's country
      reason: "Wallet funding",
      metadata: [
        { fieldName: "userId", fieldValue: @user.id.to_s },
        { fieldName: "transactionId", fieldValue: transaction.id.to_s }
      ]
    }

    headers = {
      'Authorization' => "Bearer #{@secret_key}",
      'Content-Type' => 'application/json'
    }

    response = HTTParty.post(endpoint, body: payload.to_json, headers: headers)

    if response.success?
      JSON.parse(response.body)
    else
      { success: false, error: "Pawapay API Error: #{response.code} - #{response.body}" }
    end
  rescue => e
    { success: false, error: e.message }
  end
end
