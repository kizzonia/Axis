class AccountsController < InheritedResources::Base


      layout "accounts"
      add_flash_types :success, :danger, :info, :notice

      before_action :find_account, only: [ :show, :edit, :update, :destroy]
      before_action :authenticate_user!
      def index
        @users = User.where(user_id: current_user)
        @plans = Plan.all
        @transactions = Transaction.where(user_id: current_user).order('created_at DESC')
        @transfers = Transfer.where(user_id: current_user).order('created_at DESC')
        @accounts = Account.where(user_id: current_user).order('created_at ASC')
      end

      def show
        @transfer = @account.transfers.build

      end

      def new
        @plans = Plan.all
        @account = current_user.accounts.build

      end

      def create
        @account = current_user.accounts.build(account_params)
        if @account.save
          user = User.find_by_id(@account.user_id)
          account = @account
          AccountMailer.account_email(user, account).deliver
          redirect_to root_path, notice: "Account Successfully Created"
        else
          render 'new'
        end
      end
      def edit
        @plans = Plan.all


      end

      def update
        @plans = Plan.all

        if @account.update(account_params)
          redirect_to root_path
        else
          render 'edit'
        end
      end
        private
        def find_account
          @account = Account.friendly.find(params[:id])
        end

    def account_params
      params.require(:account).permit(:balance, :city, :state, :zipcode, :phone, :username, :slug, :revenue, :status, :verify, :user_id)
    end

end
