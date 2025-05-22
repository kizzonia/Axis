class TransactionsController < ApplicationController
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
  def initiate_pawapay
     wallet = current_user.wallet
     deposit_id = params[:deposit_id]

     transaction = wallet.transactions.create(
       deposit_id: deposit_id,
       amount: params[:amount],
       status: :pending,
       payment_method: "pawapay"
     )

     if transaction.persisted?
       render json: { status: "ok" }
     else
       render json: { status: "error", message: transaction.errors.full_messages.to_sentence }, status: :unprocessable_entity
     end
   end

  def status
    @transaction = Transaction.find(params[:id])
    render json: {
      status: @transaction.status,
      error_message: @transaction.error_message
    }
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
