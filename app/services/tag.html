class OrangeMoneyService
  def initialize(user)
    @user = user
    @base_url = ENV['ORANGE_MONEY_API_URL'] || 'https://apiw.orange.cm/omcoreapis/1.0.1'
    @username = ENV['ORANGE_MONEY_USERNAME']
    @password = ENV['ORANGE_MONEY_PASSWORD']
    @msisdn = ENV['ORANGE_MONEY_MSISDN'] # This is your channelUserMsisdn
    @pin = ENV['ORANGE_MONEY_PIN']
    @auth_token = ENV['ORANGE_MONEY_AUTH_TOKEN']
  end

  def deposit(amount, subscriber_msisdn)
    ActiveRecord::Base.transaction do
      # Create transaction record
      transaction = @user.wallet.transactions.build(
        amount: amount,
        transaction_type: :deposit,
        status: :pending,
        payment_method: :orange_money,
        phone_number: subscriber_msisdn,
        user: @user
      )

      unless transaction.save
        return {
          success: false,
          error: transaction.errors.full_messages.join(', '),
          transaction: transaction
        }
      end

      # Step 1: Initialize transaction
      init_response = init_transaction('cashin')
      unless init_response[:success]
        transaction.update!(
          status: :failed,
          error_message: init_response[:error]
        )
        return {
          success: false,
          error: init_response[:error],
          transaction: transaction
        }
      end

      pay_token = init_response[:data]['payToken']

      # Step 2: Make payment
      payment_response = make_cashin_payment(
        amount: amount,
        subscriber_msisdn: subscriber_msisdn,
        order_id: transaction.reference,
        pay_token: pay_token
      )

      unless payment_response[:success]
        transaction.update!(
          status: :failed,
          error_message: payment_response[:error]
        )
        return {
          success: false,
          error: payment_response[:error],
          transaction: transaction
        }
      end

      # Step 3: Check transaction status (optional - could be async via webhook)
      status_response = check_transaction_status('cashin', pay_token)
      unless status_response[:success] && status_response[:data]['status'] == 'SUCCESSFULL'
        transaction.update!(
          status: :failed,
          error_message: status_response[:error] || 'Transaction not confirmed'
        )
        return {
          success: false,
          error: status_response[:error] || 'Transaction not confirmed',
          transaction: transaction
        }
      end

      # Update wallet balance and transaction status
      @user.wallet.lock!
      @user.wallet.balance += amount
      @user.wallet.save!

      transaction.update!(
        status: :completed,
        processed_at: Time.current,
        external_reference: payment_response[:data]['txnid']
      )

      TransactionMailer.deposit_completed(@user, transaction).deliver_later

      {
        success: true,
        message: 'Deposit successful',
        transaction: transaction
      }
    end
  rescue => e
    transaction = @user.wallet.transactions.new(
      amount: amount,
      transaction_type: :deposit,
      status: :failed,
      payment_method: :orange_money,
      phone_number: subscriber_msisdn,
      user: @user,
      error_message: "System error: #{e.message}"
    )

    {
      success: false,
      error: "Service error: #{e.message}",
      transaction: transaction,
      backtrace: Rails.env.development? ? e.backtrace : nil
    }
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

  def init_transaction(api_type)
    uri = URI("#{@base_url}/#{api_type}/init")
    response = Net::HTTP.post(uri, nil, auth_headers)
    handle_response(response)
  rescue => e
    { success: false, error: "Init failed: #{e.message}" }
  end

  def make_cashin_payment(amount:, subscriber_msisdn:, order_id:, pay_token:)
    uri = URI("#{@base_url}/cashin/pay")

    body = {
      subscriberMsisdn: subscriber_msisdn,
      channelUserMsisdn: @msisdn,
      amount: amount.to_s,
      description: "Deposit to #{@user.email}",
      orderId: order_id,
      pin: @pin,
      payToken: pay_token
    }.to_json

    response = Net::HTTP.post(uri, body, auth_headers)
    handle_response(response)
  rescue => e
    { success: false, error: "Payment failed: #{e.message}" }
  end

  def check_transaction_status(api_type, pay_token)
    uri = URI("#{@base_url}/#{api_type}/paymentstatus/#{pay_token}")
    response = Net::HTTP.get_response(uri, auth_headers)
    handle_response(response)
  rescue => e
    { success: false, error: "Status check failed: #{e.message}" }
  end

  def handle_response(response)
    parsed_response = JSON.parse(response.body)

    if response.is_a?(Net::HTTPSuccess)
      { success: true, data: parsed_response }
    else
      {
        success: false,
        error: parsed_response['message'] || "HTTP #{response.code}",
        api_response: parsed_response
      }
    end
  rescue JSON::ParserError
    {
      success: false,
      error: "HTTP #{response.code}: #{response.body.truncate(100)}"
    }
  end
end
