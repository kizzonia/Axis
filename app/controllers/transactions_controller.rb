class TransactionsController < ApplicationController
  protect_from_forgery except: :initiate_pawapay

  layout "accounts"
  add_flash_types :success, :danger, :info, :notice

  before_action :authenticate_user!
  before_action :set_wallet, only: [:new, :create, :index, :show]
  before_action :set_transaction, only: [:show]
  before_action :set_user_wallet, only: [:index, :show, :new]  # Changed from set_user_wallets

  def index
    @wallets = Wallet.where(user_id: current_user).order('created_at ASC')

    @transactions = @wallet.transactions
                          .order(created_at: :desc)
                          .page(params[:page])
                          .per(10)

    if params[:transaction_type].present?
      @transactions = @transactions.where(transaction_type: params[:transaction_type])
    end
  end

  def show
  end
  #
  # def new
  #   @transaction = @wallet.transactions.new(
  #     transaction_type: params[:type] || 'deposit',
  #     user: current_user
  #   )
  # end
  #
  # def create
  #   @transaction = @wallet.transactions.new(
  #     transaction_params.merge(
  #       status: :pending,
  #       user: current_user
  #     )
  #   )
  #
  #   if @transaction.save
  #     TransactionProcessingJob.perform_later(@transaction.id)
  #     redirect_to wallet_transaction_path(@wallet, @transaction),
  #                 notice: 'Transaction initiated successfully. Processing may take a few moments.'
  #   else
  #     render :new
  #   end
  # end
  #
  # # def create_orange_money_deposit
  # #   @wallet = current_user.wallet
  # #
  # #    begin
  # #      service = OrangeMoneyService.new(current_user)
  # #      result = service.deposit(
  # #        params[:amount].to_f,
  # #        params[:phone_number]
  # #      )
  # #
  # #      if result[:success]
  # #        redirect_to wallet_transaction_path(@wallet, result[:transaction]),
  # #                    notice: 'Orange Money deposit initiated successfully.'
  # #      else
  # #        flash[:alert] = result[:error].presence || 'Deposit failed'
  # #        redirect_to new_wallet_transaction_path(@wallet, type: 'deposit')
  # #      end
  # #    rescue => e
  # #      Rails.logger.error "Orange Money Deposit Error: #{e.message}"
  # #      flash[:alert] = "Deposit failed: #{e.message}"
  # #      redirect_to new_wallet_transaction_path(@wallet, type: 'deposit')
  # #    end
  # # end
  #
  #
  # def create_orange_money_deposit
  #   @wallet = current_user.wallet
  #
  #   @transaction = @wallet.transactions.new(
  #     amount: params[:amount],
  #     phone_number: params[:phone_number],
  #     transaction_type: 'deposit',
  #     status: :pending,
  #     user: current_user,
  #     payment_method: :orange_money
  #   )
  #
  #   if @transaction.save
  #     begin
  #       service = OrangeMoneyService.new(current_user)
  #       result = service.deposit(@transaction)
  #
  #       if result[:success]
  #         TransactionProcessingJob.perform_later(@transaction.id)
  #         redirect_to wallet_transaction_path(@wallet, @transaction),
  #                     notice: 'Orange Money deposit initiated successfully.'
  #       else
  #         @transaction.mark_as_failed!(result[:error])
  #         redirect_to new_wallet_transaction_path(@wallet, type: 'deposit'),
  #                     alert: result[:error]
  #       end
  #     rescue => e
  #       @transaction.mark_as_failed!(e.message)
  #       redirect_to new_wallet_transaction_path(@wallet, type: 'deposit'),
  #                   alert: "Deposit failed: #{e.message}"
  #     end
  #   else
  #     redirect_to new_wallet_transaction_path(@wallet, type: 'deposit'),
  #                 alert: @transaction.errors.full_messages.join(', ')
  #   end
  # end
  # def initiate_pawapay
  #   wallet = current_user.wallet
  #
  #   transaction = wallet.transactions.create(
  #     deposit_id: params[:deposit_id],
  #     amount: params[:amount],
  #     phone_number: params[:phone_number],
  #     currency: params[:currency],
  #     transaction_type: params[:transaction_type],
  #     status: :pending,
  #     payment_method: "pawapay",
  #     user: current_user
  #   )
  #
  #   if transaction.save?
  #     response = HTTParty.post("https://api.pawapay.io/v1/widget/sessions",
  #       headers: {
  #         "Authorization" => "Bearer #{ENV['PAWAPAY_SECRET_KEY']}",
  #         "Content-Type" => "application/json"
  #       },
  #       body: {
  #         depositId: transaction.deposit_id,
  #         returnUrl: pawapay_return_url(depositId: transaction.deposit_id),
  #         statementDescription: "Wallet deposit",
  #         amount: transaction.amount.to_s,
  #         msisdn: transaction.phone_number,
  #         language: "EN",
  #         country: "CMR",
  #         reason: "Wallet funding",
  #         metadata: [
  #           { fieldName: "userId", fieldValue: current_user.id.to_s },
  #           { fieldName: "depositId", fieldValue: transaction.deposit_id }
  #         ]
  #       }.to_json
  #     )
  #
  #     json = JSON.parse(response.body)
  #     if json["sessionUrl"]
  #       render json: { status: "ok", session_url: json["sessionUrl"] }
  #     else
  #       render json: { status: "error", message: json["error"] || "Could not create session" }, status: :unprocessable_entity
  #     end
  #   else
  #     render json: { status: "error", message: transaction.errors.full_messages.to_sentence }, status: :unprocessable_entity
  #   end
  # end
  #

  def initiate_pawapay
  transaction = current_user.wallet.transactions.new(
    deposit_id:       params[:deposit_id],
    amount:           params[:amount].to_i,
    phone_number:     params[:phone_number],
    currency:         params[:currency] || "XAF",
    transaction_type: params[:transaction_type] || "deposit",
    payment_method:   "pawapay",
    status:           :pending,
    user:             current_user
  )

  unless transaction.save
    return render json: { error: transaction.errors.full_messages.to_sentence }, status: :unprocessable_entity
  end

  payload = {
    depositId:            transaction.deposit_id,
    returnUrl:            "#{pawapay_return_url_url}?depositId=#{transaction.deposit_id}",
    statementDescription: "Wallet deposit",
    amount:               transaction.amount.to_i,
    msisdn:               transaction.phone_number,
    language:             "EN",
    country:              "CMR",
    reason:               "Wallet funding",
    metadata: [
      { fieldName: "userId",    fieldValue: current_user.id.to_s },
      { fieldName: "depositId", fieldValue: transaction.deposit_id }
    ]
  }

  response = HTTParty.post("https://api.pawapay.io/v1/widget/sessions",
    headers: {
      "Authorization" => "Bearer #{ENV['PAWAPAY_SECRET_KEY']}",
      "Content-Type"  => "application/json"
    },
    body: payload.to_json
  )

  Rails.logger.info "[Pawapay] Response code: #{response.code}"
  Rails.logger.info "[Pawapay] Response body: #{response.body}"

  # Pawapay returns 201 with "redirectUrl"
  if [200, 201].include?(response.code.to_i)
    data = response.parsed_response
    redirect_url = data["redirectUrl"] || data["sessionUrl"]

    if redirect_url.present?
      return render json: { sessionUrl: redirect_url }
    end
  end

  # Otherwise, error out
  error = response.parsed_response["error"] || "Unknown error"
  transaction.update(status: :failed, error_message: error)
  render json: { error: "Pawapay session creation failed: #{error}" }, status: :unprocessable_entity
rescue => e
  Rails.logger.error "[Pawapay] Exception: #{e.message}"
  transaction.update(status: :failed, error_message: e.message)
  render json: { error: "Unexpected error: #{e.message}" }, status: :internal_server_error
end



  private

  def set_wallet
    @wallet = current_user.wallet || current_user.create_wallet(balance: 0.0)
  end

  def set_transaction
    @transaction = Transaction.find(params[:id])
    # authorize @transaction
  end

  def set_user_wallet
    @user_wallet = current_user.wallet  # Single wallet instead of collection
  end

  def transaction_params
    params.require(:transaction).permit(
      :amount,
      :transaction_type,
      :payment_method,
      :deposit_id,
      :phone_number,
      :user_id
    )
  end
end
