class AccountsController < InheritedResources::Base


  layout :resolve_layout
      add_flash_types :success, :danger, :info, :notice

      before_action :find_account, only: [ :show, :edit, :update, :destroy]
      before_action :authenticate_user!
      def index
        @users = User.where(user_id: current_user)
          @accounts = Account.where(user_id: current_user).order('created_at ASC')
      end

      def show

      end

      def new
        @account = current_user.accounts.build

      end

      def create
        @account = current_user.accounts.build(account_params)
        if @account.save
          user = User.find_by_id(@account.user_id)
          account = @account
          AccountMailer.account_email(user, account).deliver_later
          redirect_to root_path, notice: "Account Successfully Created"
        else
          render 'new'
        end
      end
      def edit


      end

      def update

        if @account.update(account_params)
          redirect_to root_path
        else
          render 'edit'
        end
      end
        private
        def resolve_layout
          case action_name
          when "new", "create", "edit"
            "devise"
          when "index", "show"
            "accounts"
          else
            "application"
          end
        end

        def find_account
          @account = Account.friendly.find(params[:id])
        end

    def account_params
      params.require(:account).permit(:balance, :city, :state, :zipcode, :phone, :username, :slug, :revenue, :status, :verify, :user_id)
    end

end
