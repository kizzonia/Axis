class TransactionsController < ApplicationController

      layout "accounts"
      add_flash_types :success, :danger, :info, :notice

  before_action :authenticate_user!
  before_action :set_wallet, only: [:new, :create, :index, :show]
  before_action :set_transaction, only: [:show]

  def index
    @transactions = @wallet.transactions.order(created_at: :desc).page(params[:page]).per(10)
    # Optional: Filter by transaction type
    if params[:transaction_type].present?
     @transactions = @transactions.where(transaction_type: params[:transaction_type])
    end
  end

  def show
    authorize @transaction
  end

  def new
    @transaction = @wallet.transactions.new(transaction_type: params[:type] || 'deposit')
  end

  def create
    @transaction = @wallet.transactions.new(transaction_params)
    @transaction.status = :pending

    if @transaction.save
      # Enqueue the processing job
      TransactionProcessingJob.perform_later(@transaction.id)

      redirect_to wallet_transaction_path(@wallet, @transaction),
                  notice: 'Transaction initiated successfully. Processing may take a few moments.'
    else
      render :new
    end
  end

  # Special endpoint for Orange Money deposits
  def create_orange_money_deposit
    service = OrangeMoneyService.new(current_user)
    result = service.deposit(
      params[:amount].to_f,
      params[:phone_number]
    )

    if result[:success]
      transaction = result[:transaction]
      redirect_to wallet_transaction_path(current_user.wallet, transaction),
                  notice: 'Orange Money deposit initiated successfully.'
    else
      flash[:error] = result[:error] || 'Failed to initiate Orange Money deposit'
      redirect_to new_wallet_transaction_path(current_user.wallet, type: 'deposit')
    end
  end

  private

  def set_wallet
    @wallet = current_user.wallet || current_user.create_wallet(balance: 0.0)
  end

  def set_transaction
    @transaction = Transaction.find(params[:id])
    authorize @transaction
  end

  def transaction_params
    params.require(:transaction).permit(
      :amount,
      :transaction_type,
      :payment_method,
      :phone_number
    )
  end
end
