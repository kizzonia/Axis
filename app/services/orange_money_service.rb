class OrangeMoneyService
  def initialize(user)
    @user = user
    @api_url = ENV['ORANGE_MONEY_API_URL']
    @username = ENV['ORANGE_MONEY_USERNAME']
    @password = ENV['ORANGE_MONEY_PASSWORD']
    @msisdn = ENV['ORANGE_MONEY_MSISDN']
    @pin = ENV['ORANGE_MONEY_PIN']
    @auth_token = ENV['ORANGE_MONEY_AUTH_TOKEN']
  end

  def deposit(amount, phone_number)
    # Create transaction in a transaction block for atomicity
    ActiveRecord::Base.transaction do
      transaction = @user.wallet.transactions.build(
        amount: amount,
        transaction_type: :deposit,
        status: :pending,
        payment_method: :orange_money,
        phone_number: phone_number,
        user: @user
      )

      unless transaction.save
        return {
          success: false,
          error: transaction.errors.full_messages.join(', '),
          transaction: transaction
        }
      end

      api_response = call_orange_money_api(amount, phone_number, transaction.reference)

      if api_response[:success]
        # Update wallet balance and transaction status atomically
        @user.wallet.lock!
        @user.wallet.balance += amount
        @user.wallet.save!

        transaction.update!(
          status: :completed,
          processed_at: Time.current
        )

        TransactionMailer.deposit_completed(@user, transaction).deliver_later

        {
          success: true,
          message: 'Deposit successful',
          transaction: transaction
        }
      else
        transaction.update!(
          status: :failed,
          error_message: api_response[:error]
        )

        {
          success: false,
          error: api_response[:error],
          transaction: transaction
        }
      end
    end
  rescue => e
    # Create failed transaction if we couldn't even save the initial one
    transaction ||= @user.wallet.transactions.create!(
      amount: amount,
      transaction_type: :deposit,
      status: :failed,
      payment_method: :orange_money,
      phone_number: phone_number,
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

  def call_orange_money_api(amount, phone_number, reference)
    uri = URI("#{@api_url}/payment")

    body = {
      amount: amount,
      phone_number: phone_number,
      reference: reference,
      msisdn: @msisdn,
      pin: @pin
    }.to_json

    headers = {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{@auth_token}"
    }

    response = Net::HTTP.post(uri, body, headers)

    if response.is_a?(Net::HTTPSuccess)
      parsed_response = JSON.parse(response.body)

      # Check API-specific success indicators
      if parsed_response['status'] == 'SUCCESS'
        { success: true, data: parsed_response }
      else
        {
          success: false,
          error: parsed_response['message'] || 'API returned unsuccessful status',
          api_response: parsed_response
        }
      end
    else
      begin
        error_data = JSON.parse(response.body)
        {
          success: false,
          error: error_data['error'] || "HTTP #{response.code}",
          api_response: error_data
        }
      rescue JSON::ParserError
        {
          success: false,
          error: "HTTP #{response.code}: #{response.body.truncate(100)}"
        }
      end
    end
  rescue Timeout::Error, Errno::ECONNREFUSED => e
    { success: false, error: "Connection error: #{e.message}" }
  rescue => e
    { success: false, error: "API request failed: #{e.message}" }
  end
end
