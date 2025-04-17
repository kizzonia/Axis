class OrangeMoneyService
  API_VERSION = '1.0.2'.freeze
  BASE_URL = 'https://apiw.orange.cm/omcoreapis'.freeze

  def initialize(user)
    @user = user
    @username = ENV['ORANGE_MONEY_USERNAME']
    @password = ENV['ORANGE_MONEY_PASSWORD']
    @merchant_code = ENV['ORANGE_MERCHANT_CODE'] # MSISDN du marchand
    @pin = ENV['ORANGE_MONEY_PIN']
    @auth_token = ENV['ORANGE_MONEY_AUTH_TOKEN']
  end

  def deposit(amount, subscriber_msisdn)
    ActiveRecord::Base.transaction do
      transaction = initialize_transaction(amount, subscriber_msisdn)
      return transaction unless transaction[:success]

      # Step 1: Initialize transaction
      init_response = init_transaction(amount, subscriber_msisdn, transaction.reference)
      return handle_failure(transaction, init_response) unless init_response[:success]

      # Step 2: Process payment
      payment_response = process_payment(init_response[:data]['payToken'], transaction)
      return payment_response unless payment_response[:success]

      # Step 3: Confirm transaction
      confirmation_response = confirm_transaction(init_response[:data]['payToken'])
      return confirmation_response unless confirmation_response[:success]

      complete_transaction(transaction, payment_response[:data])
    end
  rescue => e
    handle_error(e, amount, subscriber_msisdn)
  end

  private

  # API Endpoints
  def init_transaction(amount, msisdn, order_id)
    uri = URI("#{BASE_URL}/#{API_VERSION}/cashin/init")
    body = {
      subscriberMsisdn: format_msisdn(msisdn),
      merchantMsisdn: @merchant_code,
      amount: format_amount(amount),
      orderId: order_id,
      description: "Deposit to #{@user.email}"
    }.to_json

    execute_request(:post, uri, body)
  end

  def process_payment(pay_token, transaction)
    uri = URI("#{BASE_URL}/#{API_VERSION}/cashin/pay")
    body = {
      payToken: pay_token,
      pin: @pin,
      orderId: transaction.reference
    }.to_json

    execute_request(:post, uri, body)
  end

  def confirm_transaction(pay_token)
    uri = URI("#{BASE_URL}/#{API_VERSION}/cashin/confirm/#{pay_token}")
    execute_request(:get, uri)
  end

  # Request Execution
  def execute_request(method, uri, body = nil)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    request = method == :post ? Net::HTTP::Post.new(uri) : Net::HTTP::Get.new(uri)
    request.initialize_http_head(headers)
    request.body = body if body

    response = http.request(request)
    handle_response(response)
  rescue => e
    log_error("API Request Failed: #{method.upcase} #{uri}", e, body)
    { success: false, error: e.message }
  end

  def headers
    {
      'Authorization' => "Bearer #{@auth_token}",
      'X-AUTH-TOKEN' => Base64.strict_encode64("#{@username}:#{@password}"),
      'Content-Type' => 'application/json',
      'Accept' => 'application/json',
      'X-Correlation-ID' => SecureRandom.uuid
    }
  end

  # Formatting Helpers
  def format_msisdn(phone)
    phone.to_s.gsub(/^\+237/, '').gsub(/\D/, '')
  end

  def format_amount(amount)
    # Convert to smallest currency unit (centimes for XAF)
    (amount.to_f * 100).to_i.to_s
  end

  # Transaction Management
  def initialize_transaction(amount, msisdn)
    transaction = @user.wallet.transactions.new(
      amount: amount,
      transaction_type: :deposit,
      status: :pending,
      payment_method: :orange_money,
      phone_number: msisdn,
      user: @user
    )

    transaction.save ?
      { success: true, transaction: transaction } :
      { success: false, error: transaction.errors.full_messages.join(', '), transaction: transaction }
  end

  def handle_response(response)
    parsed_body = parse_response(response.body)

    if response.is_a?(Net::HTTPSuccess)
      { success: true, data: parsed_body }
    else
      error_message = parsed_body['message'] || "HTTP #{response.code}"
      { success: false, error: error_message, response: parsed_body }
    end
  end

  def parse_response(body)
    JSON.parse(body)
  rescue JSON::ParserError
    { 'message' => body }
  end

  def complete_transaction(transaction, response_data)
    @user.wallet.with_lock do
      @user.wallet.balance += transaction.amount
      @user.wallet.save!
    end

    transaction.update!(
      status: :completed,
      processed_at: Time.current,
      external_reference: response_data['txnid'],
      metadata: response_data
    )

    TransactionMailer.deposit_completed(@user, transaction).deliver_later
    { success: true, transaction: transaction }
  end

  # Error Handling
  def handle_failure(transaction, response)
    transaction.update!(
      status: :failed,
      error_message: response[:error],
      metadata: response[:response]
    )
    response
  end

  def handle_error(error, amount, msisdn)
    transaction = @user.wallet.transactions.new(
      amount: amount,
      transaction_type: :deposit,
      status: :failed,
      payment_method: :orange_money,
      phone_number: msisdn,
      error_message: "System error: #{error.message}",
      user: @user
    )

    log_error("Transaction Error", error)
    { success: false, error: error.message, transaction: transaction }
  end

  def log_error(context, error, body = nil)
    Rails.logger.error("[Orange Money] #{context}")
    Rails.logger.error("Message: #{error.message}")
    Rails.logger.error("Backtrace:\n#{error.backtrace.join("\n")}")
    Rails.logger.error("Request Body: #{body}") if body
  end
end
