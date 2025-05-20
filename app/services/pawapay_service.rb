# app/services/pawapay_service.rb
class PawapayService
  BASE_URL = 'https://api.pawapay.io/v1'.freeze

  def initialize(user)
    @user       = user
    @merchant_id = ENV.fetch('PAWAPAY_MERCHANT_ID')
    @secret_key  = ENV.fetch('PAWAPAY_SECRET_KEY')
  end

  # Creates a Payment‑Page session and returns the parsed JSON.
  # On error, returns { success: false, error: "…" }
  def create_deposit_session(transaction)
    url     = "#{BASE_URL}/widget/sessions"
    payload = {
      depositId:            transaction.deposit_id,
      returnUrl:            Rails.application.routes.url_helpers.pawapay_callback_url(
                              host: ENV.fetch('APP_HOST'),
                              protocol: Rails.env.production? ? 'https' : 'http'
                            ),
      statementDescription: truncate_desc("Wallet deposit #{@user.id}"),
      amount:               transaction.amount.to_s,
      msisdn:               transaction.phone_number,
      language:             'EN',
      country:              transaction.country || 'CMR',    # ISO‑3 code (e.g. 'CMR' or 'ZMB')
      reason:               'Wallet funding',
      metadata: [
        { fieldName:  'userId',        fieldValue: @user.id.to_s },
        { fieldName:  'transactionId', fieldValue: transaction.id.to_s }
      ]
    }
    headers = {
      'Authorization' => "Bearer #{@secret_key}",
      'Content-Type'  => 'application/json'
    }

    resp = HTTParty.post(url, body: payload.to_json, headers: headers)
    parse_response(resp)
  end

  private

  # Pawapay requires statementDescription be 4–22 characters
  def truncate_desc(str)
    str.truncate(22, omission: '')
  end

  def parse_response(response)
    if response.success?
      JSON.parse(response.body)       # => { "sessionUrl" => "...", ... }
    else
      { success: false, error: "API #{response.code}: #{response.body}" }
    end
  rescue StandardError => e
    { success: false, error: e.message }
  end
end
