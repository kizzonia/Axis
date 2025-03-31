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
    # Create a pending transaction
    transaction = @user.wallet.transactions.create!(
      amount: amount,
      transaction_type: :deposit,
      status: :pending,
      payment_method: :orange_money
    )

    # Call Orange Money API
    response = call_orange_money_api(amount, phone_number, transaction.reference)

    if response.success?
      transaction.update!(status: :completed)
      @user.wallet.deposit(amount)
      TransactionMailer.deposit_completed(@user, transaction).deliver_later
      { success: true, message: 'Deposit successful' }
    else
      transaction.update!(status: :failed)
      { success: false, message: 'Deposit failed' }
    end
  end

  private

  def call_orange_money_api(amount, phone_number, reference)
    # This is a simplified version. You'll need to implement the actual API call
    # according to Orange Money's API documentation
    uri = URI("#{@api_url}/payment")

    headers = {
      'Content-Type' => 'application/json',
      'X-AUTH-TOKEN' => @auth_token,
      'Authorization' => "Basic #{Base64.strict_encode64("#{@username}:#{@password}")}"
    }

    body = {
      amount: amount,
      customer_msisdn: phone_number,
      merchant_msisdn: @msisdn,
      pin: @pin,
      reference: reference
    }.to_json

    response = Net::HTTP.post(uri, body, headers)

    # Parse response and return appropriate result
    JSON.parse(response.body)
  rescue => e
    { success: false, error: e.message }
  end
end
