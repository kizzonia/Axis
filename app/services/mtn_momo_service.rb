class MtnMomoService
  def initialize(user)
    @user = user
    @api_url = ENV['MTN_MOMO_API_URL']
    @api_key = ENV['MTN_MOMO_API_KEY']
    @user_id = ENV['MTN_MOMO_USER_ID']
    @primary_key = ENV['MTN_MOMO_PRIMARY_KEY']
  end

  def deposit(amount, phone_number)
    # Create a pending transaction
    transaction = @user.wallet.transactions.create!(
      amount: amount,
      transaction_type: :deposit,
      status: :pending,
      payment_method: :mtn_momo
    )

    # Call MTN Mobile Money API
    response = call_mtn_momo_api(amount, phone_number, transaction.reference)

    if response[:success]
      transaction.update!(status: :completed)
      @user.wallet.deposit(amount)
      TransactionMailer.deposit_completed(@user, transaction).deliver_later
      { success: true, message: 'Deposit successful' }
    else
      transaction.update!(status: :failed)
      { success: false, message: response[:error] || 'Deposit failed' }
    end
  end

  private

  def call_mtn_momo_api(amount, phone_number, reference)
    # This is a simplified version. You'll need to implement the actual API call
    # according to MTN Mobile Money's API documentation
    uri = URI("#{@api_url}/collection/v1_0/requesttopay")

    headers = {
      'Content-Type' => 'application/json',
      'Ocp-Apim-Subscription-Key' => @primary_key,
      'X-Reference-Id' => reference,
      'X-Target-Environment' => 'sandbox'
    }

    body = {
      amount: amount,
      currency: 'XAF',
      externalId: reference,
      payer: {
        partyIdType: 'MSISDN',
        partyId: phone_number
      },
      payerMessage: 'Wallet deposit',
      payeeNote: 'Deposit to e-commerce wallet'
    }.to_json

    response = Net::HTTP.post(uri, body, headers)

    # Parse response and return appropriate result
    JSON.parse(response.body)
  rescue => e
    { success: false, error: e.message }
  end
end
