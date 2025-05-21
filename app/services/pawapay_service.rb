class PawapayService
  BASE_URL = 'https://api.pawapay.io/v1'.freeze

  def initialize(user)
    @user = user
     @secret_key = ENV['PAWAPAY_SECRET_KEY']
  end

  def create_deposit_session(transaction)
    endpoint = "#{BASE_URL}/widget/sessions"

    payload = {
      depositId: transaction.deposit_id,
      returnUrl: Rails.application.routes.url_helpers.pawapay_callback_url(
        host: ENV['APP_HOST'],
        protocol: Rails.env.production? ? 'https' : 'http'
      ),
      statementDescription: "Wallet deposit #{@user.id}",
      amount: transaction.amount.to_s,
      currency: transaction.currency || 'XAF', # fallback if nil
      msisdn: transaction.phone_number,
      language: 'EN',
      reason: 'Wallet funding',
      metadata: [
        { fieldName: 'userId', fieldValue: @user.id.to_s },
        { fieldName: 'transactionId', fieldValue: transaction.id.to_s }
      ]
    }

    headers = {
      'Authorization' => "Bearer #{@secret_key}",
      'Content-Type' => 'application/json'
    }

    begin
      response = HTTParty.post(endpoint, body: payload.to_json, headers: headers)
      log_request_and_response(payload, response)

      if response.success?
        body = JSON.parse(response.body)
        if body['sessionUrl'].present?
          return { success: true, session_url: body['sessionUrl'] }
        else
          return { success: false, error: "Missing sessionUrl in response: #{body}" }
        end
      else
        return { success: false, error: "API Error #{response.code}: #{response.body}" }
      end
    rescue => e
      Rails.logger.error "[PawapayService] Exception: #{e.message}"
      return { success: false, error: "Exception: #{e.message}" }
    end
  end

  private

  def log_request_and_response(payload, response)
    Rails.logger.debug "[PawapayService] Payload: #{payload.to_json}"
    Rails.logger.debug "[PawapayService] Response Code: #{response.code}"
    Rails.logger.debug "[PawapayService] Response Body: #{response.body}"
  end
end
