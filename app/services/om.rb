# class OrangeMoneyService
#   def initialize(user)
#     @user = user
#     @api_url = ENV['ORANGE_MONEY_API_URL']
#     @username = ENV['ORANGE_MONEY_USERNAME']
#     @password = ENV['ORANGE_MONEY_PASSWORD']
#     @msisdn = ENV['ORANGE_MONEY_MSISDN']
#     @pin = ENV['ORANGE_MONEY_PIN']
#     @auth_token = ENV['ORANGE_MONEY_AUTH_TOKEN']
#   end
#
#   def deposit(amount, phone_number)
#     # Create a pending transaction
#     transaction = @user.wallet.transactions.create!(
#       amount: amount,
#       transaction_type: :deposit,
#       status: :pending,
#       payment_method: :orange_money,
#       phone_number: phone_number,
#       user: @user  # Explicitly set the user
#
#     )
#
#     # Call Orange Money API
#     # response = call_orange_money_api(amount, phone_number, transaction.reference)
#
#     if transaction.save
#          response = call_orange_money_api(amount, phone_number, transaction.reference)
#
#          # Fix: Change response.success? to check the hash key
#          if response.is_a?(Hash) && response[:success]
#            transaction.update!(status: :completed)
#            @user.wallet.deposit(amount)
#            TransactionMailer.deposit_completed(@user, transaction).deliver_later
#            { success: true, message: 'Deposit successful', transaction: transaction }
#          else
#            error_msg = response[:error] || 'API request failed'
#            transaction.update!(status: :failed, error_message: error_msg)
#            { success: false, message: 'Deposit failed', error: error_msg }
#          end
#        else
#          { success: false, message: 'Transaction validation failed', error: transaction.errors.full_messages.join(', ') }
#        end
#      rescue => e
#        {
#          success: false,
#          error: "Service error: #{e.message}",
#          backtrace: Rails.env.development? ? e.backtrace : nil
#        }
#      end
#
#   private
#
#
#     def call_orange_money_api(amount, phone_number, reference)
#       uri = URI("#{@api_url}/payment")
#       # ... existing request setup ...
#
#       response = Net::HTTP.post(uri, body, headers)
#
#       # Improved response parsing with error handling
#       begin
#         parsed_response = JSON.parse(response.body)
#         {
#           success: response.is_a?(Net::HTTPSuccess),
#           status: response.code,
#           data: parsed_response
#         }
#       rescue JSON::ParserError => e
#         {
#           success: false,
#           error: "Invalid API response: #{e.message}",
#           raw_response: response.body
#         }
#       end
#     rescue => e
#       {
#         success: false,
#         error: "API request failed: #{e.message}"
#       }
#     end
# end
