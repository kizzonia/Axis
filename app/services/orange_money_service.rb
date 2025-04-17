class OrangeMoneyService
  API_VERSION = '1.0.2'.freeze

  def initialize(user)
    @user = user
    @base_url = 'https://apiw.orange.cm/omcoreapis'
    @username = ENV['ORANGE_MONEY_USERNAME']
    @password = ENV['ORANGE_MONEY_PASSWORD']
    @msisdn = ENV['ORANGE_MONEY_MSISDN'] # ChannelUserMsisdn without country code
    @pin = ENV['ORANGE_MONEY_PIN']
    @auth_token = ENV['ORANGE_MONEY_AUTH_TOKEN']
  end

  def deposit(amount, subscriber_msisdn)
    ActiveRecord::Base.transaction do
      transaction = create_initial_transaction(amount, subscriber_msisdn)
      return transaction unless transaction[:success]

      init_response = init_transaction('cashin')
      return handle_init_failure(transaction[:transaction], init_response) unless init_response[:success]

      payment_response = process_payment(transaction[:transaction], init_response[:data]['payToken'], amount, subscriber_msisdn)
      return payment_response unless payment_response[:success]

      status_response = verify_transaction_status('cashin', init_response[:data]['payToken'])
      return status_response unless status_response[:success]

      complete_transaction(transaction[:transaction], payment_response[:data]['txnid'], amount)
    end
  rescue => e
    handle_transaction_error(e, amount, subscriber_msisdn)
  end

  private

  def auth_headers
    {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{@auth_token}",
      'X-AUTH-TOKEN' => Base64.strict_encode64("#{@username}:#{@password}"),
      'accept' => 'application/json'
    }
  end

  # API Request Methods
  def init_transaction(api_type)
    uri = URI("#{@base_url}/#{api_type}/#{API_VERSION}/init")
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      request = Net::HTTP::Post.new(uri)
      auth_headers.each { |k, v| request[k] = v }
      http.request(request)
    end
    handle_response(response)
  rescue => e
    log_error("Init Transaction Failed", e, uri.to_s)
    { success: false, error: "Init failed: #{e.message}" }
  end

  def make_cashin_payment(pay_token:, amount:, subscriber_msisdn:, order_id:)
    uri = URI("#{@base_url}/cashin/#{API_VERSION}/pay")
    body = payment_request_body(pay_token, amount, subscriber_msisdn, order_id)

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      request = Net::HTTP::Post.new(uri)
      auth_headers.each { |k, v| request[k] = v }
      request.body = body
      http.request(request)
    end
    handle_response(response)
  rescue => e
    log_error("Cashin Payment Failed", e, uri.to_s, body)
    { success: false, error: "Payment failed: #{e.message}" }
  end

  def check_transaction_status(api_type, pay_token)
    uri = URI("#{@base_url}/#{api_type}/#{API_VERSION}/paymentstatus/#{pay_token}")
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      request = Net::HTTP::Get.new(uri)
      auth_headers.each { |k, v| request[k] = v }
      http.request(request)
    end
    handle_response(response)
  rescue => e
    log_error("Status Check Failed", e, uri.to_s)
    { success: false, error: "Status check failed: #{e.message}" }
  end

  # Helper Methods
  def payment_request_body(pay_token, amount, subscriber_msisdn, order_id)
    {
      subscriberMsisdn: format_phone(subscriber_msisdn),
      channelUserMsisdn: @msisdn,
      amount: format_amount(amount),
      description: "Deposit to #{@user.email}",
      orderId: order_id,
      pin: @pin,
      payToken: pay_token
    }.to_json
  end

  def format_phone(phone)
    phone.gsub(/\A\+237/, '') # Remove country code if present
  end

  def format_amount(amount)
    # Convert to integer XAF (remove decimals)
    (amount.to_f * 100).to_i.to_s
  end

  def handle_response(response)
    parsed_response = parse_response(response)

    if response.is_a?(Net::HTTPSuccess)
      { success: true, data: parsed_response }
    else
      error_message = parsed_response.dig('message') || "HTTP #{response.code}"
      { success: false, error: error_message, api_response: parsed_response }
    end
  rescue JSON::ParserError
    { success: false, error: "Invalid response: #{response.body.truncate(100)}" }
  end

  def parse_response(response)
    JSON.parse(response.body)
  rescue JSON::ParserError
    { 'message' => response.body }
  end

  # Transaction Management
  def create_initial_transaction(amount, subscriber_msisdn)
    transaction = @user.wallet.transactions.new(
      amount: amount,
      transaction_type: :deposit,
      status: :pending,
      payment_method: :orange_money,
      phone_number: subscriber_msisdn,
      user: @user
    )

    if transaction.save
      { success: true, transaction: transaction }
    else
      { success: false, error: transaction.errors.full_messages.join(', '), transaction: transaction }
    end
  end

  def process_payment(transaction, pay_token, amount, subscriber_msisdn)
    payment_response = make_cashin_payment(
      pay_token: pay_token,
      amount: amount,
      subscriber_msisdn: subscriber_msisdn,
      order_id: transaction.reference
    )

    unless payment_response[:success]
      transaction.update!(status: :failed, error_message: payment_response[:error])
    end

    payment_response
  end

  def verify_transaction_status(api_type, pay_token)
    status_response = check_transaction_status(api_type, pay_token)

    if status_response[:success] && status_response[:data]['status'] == 'SUCCESSFULL'
      status_response
    else
      error = status_response[:error] || 'Transaction not confirmed'
      { success: false, error: error }
    end
  end

  def complete_transaction(transaction, txnid, amount)
    @user.wallet.with_lock do
      @user.wallet.balance += amount
      @user.wallet.save!
    end

    transaction.update!(
      status: :completed,
      processed_at: Time.current,
      external_reference: txnid
    )

    TransactionMailer.deposit_completed(@user, transaction).deliver_later
    { success: true, message: 'Deposit successful', transaction: transaction }
  end

  # Error Handling
  def handle_init_failure(transaction, response)
    transaction.update!(status: :failed, error_message: response[:error])
    response
  end

  def handle_transaction_error(error, amount, subscriber_msisdn)
    transaction = @user.wallet.transactions.new(
      amount: amount,
      transaction_type: :deposit,
      status: :failed,
      payment_method: :orange_money,
      phone_number: subscriber_msisdn,
      user: @user,
      error_message: "System error: #{error.message}"
    )

    log_error("Transaction Error", error)

    {
      success: false,
      error: "Service error: #{error.message}",
      transaction: transaction,
      backtrace: Rails.env.development? ? error.backtrace : nil
    }
  end

  def log_error(context, error, url = nil, body = nil)
    Rails.logger.error {
      <<~ERROR
        Orange Money Error - #{context}
        URL: #{url}
        Request Body: #{body}
        Message: #{error.message}
        Backtrace: #{error.backtrace.join("\n")}
      ERROR
    }
  end
end
