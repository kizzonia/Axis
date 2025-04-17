class OrangeMoneyService
  def initialize(user)
    @user = user
    @base_url = 'https://api-s1.orange.cm/omcoreapis/1.0.2'
    @username = ENV['ORANGE_MONEY_USERNAME']
    @password = ENV['ORANGE_MONEY_PASSWORD']
    @x_auth_token = ENV['ORANGE_MONEY_AUTH_TOKEN']
    @msisdn = ENV['ORANGE_MONEY_MSISDN']
    @pin = ENV['ORANGE_MONEY_PIN']
    # @notif_url = ENV['ORANGE_MONEY_NOTIF_URL']
  end

  def deposit(transaction)
    begin
      # Step 1: Get Access Token
      access_token_response = get_access_token
      return service_error(transaction, access_token_response[:error]) unless access_token_response[:success]

      # Step 2: Initialize Payment
      init_response = init_transaction(access_token_response[:access_token])
      return service_error(transaction, init_response[:error]) unless init_response[:success]

      # Step 3: Make Payment
      payment_response = make_payment(
        access_token: access_token_response[:access_token],
        transaction: transaction,
        pay_token: init_response[:data]['payToken']
      )
      return service_error(transaction, payment_response[:error]) unless payment_response[:success]

      # Step 4: Verify Transaction
      status_response = check_transaction_status(
        access_token_response[:access_token],
        payment_response[:data]['payToken']
      )
      return service_error(transaction, status_response[:error]) unless status_response[:success]

      complete_transaction(transaction, payment_response)
      { success: true, transaction: transaction }
    rescue => e
      handle_service_error(transaction, e)
    end
  end

  private

  def get_access_token
    uri = URI.parse('https://api-s1.orange.cm/token')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(uri.path)
    request.content_type = 'application/x-www-form-urlencoded'
    request['Authorization'] = "Basic #{Base64.strict_encode64("#{@username}:#{@password}")}"
    request.body = URI.encode_www_form(grant_type: 'client_credentials')

    response = http.request(request)
    handle_token_response(response)
  rescue => e
    { success: false, error: e.message }
  end

  def init_transaction(access_token)
    uri = URI("#{@base_url}/mp/init")
    headers = om_headers(access_token)
    response = Net::HTTP.post(uri, nil, headers)
    handle_response(response)
  end

  def make_payment(access_token:, transaction:, pay_token:)
    uri = URI("#{@base_url}/mp/pay")
    headers = om_headers(access_token)

    body = payment_body(transaction, pay_token).to_json
    response = Net::HTTP.post(uri, body, headers)
    handle_response(response)
  end

  def check_transaction_status(access_token, pay_token)
    uri = URI("#{@base_url}/mp/paymentstatus/#{pay_token}")
    headers = om_headers(access_token)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri, headers)
    response = http.request(request)
    handle_response(response)
  end

  def payment_body(transaction, pay_token)
    {
      notifUrl: @notif_url,
      channelUserMsisdn: @msisdn,
      amount: transaction.amount.to_s,
      subscriberMsisdn: transaction.phone_number,
      pin: @pin,
      orderId: transaction.reference,
      description: "Deposit to #{@user.email}",
      payToken: pay_token
    }
  end

  def om_headers(access_token)
    {
      'X-AUTH-TOKEN' => @x_auth_token,
      'Authorization' => "Bearer #{access_token}",
      'Content-Type' => 'application/json'
    }
  end

  def handle_token_response(response)
    body = JSON.parse(response.body) rescue {}
    response.is_a?(Net::HTTPSuccess) ?
      { success: true, access_token: body['access_token'] } :
      { success: false, error: body['error_description'] || "HTTP #{response.code}" }
  end

  def handle_response(response)
    body = JSON.parse(response.body) rescue {}
    response.is_a?(Net::HTTPSuccess) ?
      { success: true, data: body['data'] || body } :
      { success: false, error: body['message'] || "HTTP #{response.code}" }
  end

  def complete_transaction(transaction, payment_response)
    ActiveRecord::Base.transaction do
      @user.wallet.with_lock do
        @user.wallet.balance += transaction.amount
        @user.wallet.save!
        transaction.update!(
          status: :completed,
          processed_at: Time.current,
          external_reference: payment_response[:data]['txnid'],
          metadata: payment_response[:data].to_json
        )
      end
    end
  end

  def service_error(transaction, error)
    transaction.update!(status: :failed, error_message: error)
    { success: false, error: error, transaction: transaction }
  end

  def handle_service_error(transaction, error)
    transaction.update!(
      status: :failed,
      error_message: "System error: #{error.message}"
    )
    { success: false, error: error.message, transaction: transaction }
  end
end
